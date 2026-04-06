output "queue_url" {
  value = aws_sqs_queue.this.id
}

output "queue_arn" {
  value = aws_sqs_queue.this.arn
}

output "dlq_url" {
  value = aws_sqs_queue.dlq.id
}

output "dlq_arn" {
  value = aws_sqs_queue.dlq.arn
}

output "sns_topic_arn" {
  value = try(aws_sns_topic.this[0].arn, null)
}

output "sns_topic_name" {
  value = try(aws_sns_topic.this[0].name, null)
}
