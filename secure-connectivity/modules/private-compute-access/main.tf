# Private compute with Session Manager as the only administrative access
# path: no public IP, no SSH ingress, no key pair, no bastion. Session
# Manager reaches the instance through IAM authorization plus (if
# enable_vpc_endpoints) VPC interface endpoints, entirely inside the VPC.

locals {
  tags = merge(var.tags, {
    Module    = "private-compute-access"
    ManagedBy = "terraform"
  })

  subnet_for_instance = [
    for i in range(var.instance_count) :
    var.private_subnet_ids[i % length(var.private_subnet_ids)]
  ]
}

data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

# --- Security groups --------------------------------------------------------

resource "aws_security_group" "instance" {
  name        = "${var.name}-instance"
  description = "Private instances -- no ingress rules at all; administered via Session Manager"
  vpc_id      = var.vpc_id

  tags = merge(local.tags, { Name = "${var.name}-instance" })
}

resource "aws_vpc_security_group_egress_rule" "instance_https" {
  security_group_id = aws_security_group.instance.id
  description       = "HTTPS egress for SSM, CloudWatch, package repos"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

resource "aws_security_group" "vpc_endpoints" {
  count = var.enable_vpc_endpoints ? 1 : 0

  name        = "${var.name}-vpc-endpoints"
  description = "SSM interface endpoints -- HTTPS ingress from within the VPC only"
  vpc_id      = var.vpc_id

  tags = merge(local.tags, { Name = "${var.name}-vpc-endpoints" })
}

resource "aws_vpc_security_group_ingress_rule" "vpc_endpoints_from_vpc" {
  count = var.enable_vpc_endpoints ? 1 : 0

  security_group_id = aws_security_group.vpc_endpoints[0].id
  description       = "HTTPS from anything in the VPC -- endpoints don't discriminate by SG, only network reachability matters here"
  cidr_ipv4         = var.vpc_cidr
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

# --- VPC endpoints: required for SSM connectivity without a NAT Gateway -----

resource "aws_vpc_endpoint" "ssm" {
  for_each = var.enable_vpc_endpoints ? toset(["ssm", "ssmmessages", "ec2messages"]) : toset([])

  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.${each.key}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [aws_security_group.vpc_endpoints[0].id]
  private_dns_enabled = true

  tags = merge(local.tags, { Name = "${var.name}-${each.key}" })
}

resource "aws_vpc_endpoint" "s3" {
  count = var.enable_vpc_endpoints ? 1 : 0

  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = var.route_table_ids

  tags = merge(local.tags, { Name = "${var.name}-s3" })
}

data "aws_region" "current" {}

# --- IAM: SSM only, no SSH key anywhere --------------------------------------

data "aws_iam_policy_document" "instance_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "instance" {
  name               = "${var.name}-instance"
  assume_role_policy = data.aws_iam_policy_document.instance_assume.json

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.instance.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "instance" {
  name = "${var.name}-instance"
  role = aws_iam_role.instance.name

  tags = local.tags
}

# --- Optional session logging -----------------------------------------------

resource "aws_cloudwatch_log_group" "sessions" {
  count = var.enable_session_logging ? 1 : 0

  name              = "/ssm/sessions/${var.name}"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.kms_key_arn != "" ? var.kms_key_arn : null

  tags = local.tags
}

# Session Manager preferences document -- routes session output to the log
# group above. Scoped account-wide by AWS's design (there is only one
# SSM-SessionManagerRunShell document per account/region), so this module
# should be the only thing managing session logging destination in a given
# account+region.
resource "aws_ssm_document" "session_preferences" {
  count = var.enable_session_logging ? 1 : 0

  name            = "SSM-SessionManagerRunShell"
  document_type   = "Session"
  document_format = "JSON"

  content = jsonencode({
    schemaVersion = "1.0"
    description   = "Session Manager preferences: log to CloudWatch"
    sessionType   = "Standard_Stream"
    inputs = {
      cloudWatchLogGroupName      = aws_cloudwatch_log_group.sessions[0].name
      cloudWatchEncryptionEnabled = var.kms_key_arn != ""
      cloudWatchStreamingEnabled  = true
      s3EncryptionEnabled         = false
      idleSessionTimeout          = "20"
    }
  })

  tags = local.tags
}

data "aws_iam_policy_document" "session_logging_publish" {
  count = var.enable_session_logging ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]
    # Scoped to this module's own session log group, not "*".
    resources = ["${aws_cloudwatch_log_group.sessions[0].arn}:*"]
  }
}

resource "aws_iam_role_policy" "session_logging_publish" {
  count = var.enable_session_logging ? 1 : 0

  name   = "${var.name}-session-logging"
  role   = aws_iam_role.instance.id
  policy = data.aws_iam_policy_document.session_logging_publish[0].json
}

# --- Private instances --------------------------------------------------------

resource "aws_instance" "this" {
  count = var.instance_count

  ami                    = data.aws_ssm_parameter.al2023_ami.value
  instance_type          = var.instance_type
  subnet_id              = local.subnet_for_instance[count.index]
  vpc_security_group_ids = [aws_security_group.instance.id]
  iam_instance_profile   = aws_iam_instance_profile.instance.name

  associate_public_ip_address = false

  metadata_options {
    http_tokens                 = "required" # IMDSv2 enforced
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 1
  }

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
    kms_key_id  = var.kms_key_arn != "" ? var.kms_key_arn : null
  }

  tags = merge(local.tags, { Name = "${var.name}-${count.index}" })
}
