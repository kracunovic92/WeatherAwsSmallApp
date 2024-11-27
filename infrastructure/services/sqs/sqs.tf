data "aws_iam_policy_document" "queue" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions = ["sqs:SendMessage","sqs:ReciveMessage"]
    resources = ["*"]
    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = ["*"]
    }

  }
}


resource "aws_sqs_queue" "s3_notification_sqs" {
  
  name = var.sqs_notification_name

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount = 3
  })
  
}

resource "aws_sqs_queue_policy" "sqs_policy" {
  queue_url = aws_sqs_queue.s3_notification_sqs.id
  policy = data.aws_iam_policy_document.queue.json
  
}


resource "aws_sqs_queue" "dlq" {
  name = var.sqs_deadq_name
  
}



output "notification_sqs_arn" {
    value = aws_sqs_queue.s3_notification_sqs.arn
}
output "notification_sqs_url" {
  value = aws_sqs_queue.s3_notification_sqs.id
  
}
output "dlq_arn" {
  value = aws_sqs_queue.dlq.arn
  
}