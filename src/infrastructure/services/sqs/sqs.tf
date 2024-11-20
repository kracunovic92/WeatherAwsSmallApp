data "aws_iam_policy_document" "queue" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.s3_notification_sqs.arn]
    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = ["${var.bucket_arn}"]
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
output "dlq_arn" {
  value = aws_sqs_queue.dlq.arn
  
}