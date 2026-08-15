# Hardened, optional public access gateway. This is NOT the default access
# pattern in this portfolio -- private-compute-access (Session Manager) is
# preferred. This module exists for the case a team still needs SSH
# compatibility (legacy tooling, non-AWS-aware clients) and documents the
# tradeoffs of that choice rather than pretending source-IP restriction is
# equivalent to identity-aware access.
#
# Hard constraints enforced in variables.tf: admin_cidr_allowlist can never
# be 0.0.0.0/0 or ::/0, and is required (no default-open mode exists).

locals {
  tags = merge(var.tags, {
    Module    = "access-gateway"
    ManagedBy = "terraform"
  })
}

data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

# --- Security groups --------------------------------------------------------

resource "aws_security_group" "gateway" {
  name        = "${var.name}-gateway"
  description = "SSH ingress from an explicit admin CIDR allowlist only; egress restricted to the target security group"
  vpc_id      = var.vpc_id

  tags = merge(local.tags, { Name = "${var.name}-gateway" })
}

resource "aws_vpc_security_group_ingress_rule" "gateway_ssh" {
  for_each = toset(var.admin_cidr_allowlist)

  security_group_id = aws_security_group.gateway.id
  description        = "SSH from an explicitly allowlisted admin CIDR"
  cidr_ipv4           = each.value
  from_port            = 22
  to_port               = 22
  ip_protocol           = "tcp"
}

# Egress is SG-to-SG only, to the private target's security group -- this
# gateway cannot reach anything else in the VPC, and cannot reach the
# internet at all except via the HTTPS rule below (needed for SSM).
resource "aws_vpc_security_group_egress_rule" "gateway_to_target" {
  security_group_id           = aws_security_group.gateway.id
  description                  = "SSH forwarding to the private target's security group only"
  referenced_security_group_id = var.target_security_group_id
  from_port                     = 22
  to_port                        = 22
  ip_protocol                    = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "gateway_https" {
  security_group_id = aws_security_group.gateway.id
  description        = "HTTPS egress for SSM (gateway itself is administered via Session Manager) and package repos"
  cidr_ipv4           = "0.0.0.0/0"
  from_port            = 443
  to_port               = 443
  ip_protocol            = "tcp"
}

# --- IAM: gateway administered via SSM regardless of whether key_name is set

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

resource "aws_iam_role" "gateway" {
  name               = "${var.name}-gateway"
  assume_role_policy = data.aws_iam_policy_document.instance_assume.json

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.gateway.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "gateway" {
  name = "${var.name}-gateway"
  role = aws_iam_role.gateway.name

  tags = local.tags
}

# --- Launch template + single-instance ASG for automated replacement -------
#
# desired_capacity = 1 gives automated replacement on instance failure, NOT
# high availability -- there is exactly one gateway. See README.md for the
# replaceable/fault-tolerant/highly-available distinction.

resource "aws_launch_template" "gateway" {
  name_prefix   = "${var.name}-gateway-"
  image_id      = data.aws_ssm_parameter.al2023_ami.value
  instance_type = var.instance_type
  key_name      = var.key_name != "" ? var.key_name : null

  iam_instance_profile {
    name = aws_iam_instance_profile.gateway.name
  }

  vpc_security_group_ids = [aws_security_group.gateway.id]

  metadata_options {
    http_tokens                = "required" # IMDSv2 enforced
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 1
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 20
      volume_type            = "gp3"
      encrypted               = true
      delete_on_termination   = true
    }
  }

  monitoring {
    enabled = var.enable_detailed_monitoring
  }

  tag_specifications {
    resource_type = "instance"
    tags          = merge(local.tags, { Name = "${var.name}-gateway" })
  }

  tags = local.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "gateway" {
  name                = "${var.name}-gateway-asg"
  vpc_zone_identifier = var.public_subnet_ids
  min_size            = 1
  max_size            = 1
  desired_capacity    = 1

  health_check_type        = "EC2"
  health_check_grace_period = 60

  launch_template {
    id      = aws_launch_template.gateway.id
    version = "$Latest"
  }

  dynamic "tag" {
    for_each = merge(local.tags, { Name = "${var.name}-gateway" })
    content {
      key                 = tag.key
      value                = tag.value
      propagate_at_launch  = true
    }
  }
}

# --- Observability -----------------------------------------------------------

resource "aws_cloudwatch_log_group" "gateway" {
  name              = "/access-gateway/${var.name}"
  retention_in_days = var.log_retention_days

  tags = local.tags
}

resource "aws_cloudwatch_metric_alarm" "no_healthy_gateway" {
  alarm_name          = "${var.name}-gateway-not-in-service"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name          = "GroupInServiceInstances"
  namespace             = "AWS/AutoScaling"
  period                 = 60
  statistic               = "Average"
  threshold                = 1
  treat_missing_data        = "breaching"
  alarm_description          = "The access gateway has no healthy in-service instance -- min/desired/max are all 1, so this means the gateway is currently down or mid-replacement."

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.gateway.name
  }

  tags = local.tags
}
