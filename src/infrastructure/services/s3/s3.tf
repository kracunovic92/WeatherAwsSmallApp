data "aws_iam_policy_document" "s3"{

    statement {
      effect = "Allow"

      principals {
        type =  "AWS"
        identifiers = [var.role_arn]
      }
      actions = [
        "s3:PutObject",
        "s3:PutObjectAcl"
      ]
      resources = ["${aws_s3_bucket.weather_bucket.arn}/*"]

    }
    
}

resource "aws_s3_bucket_policy" "s3_policy" {
    bucket = aws_s3_bucket.weather_bucket.id
    policy = data.aws_iam_policy_document.s3.json
  
}

resource "aws_s3_bucket" "weather_bucket" {

    bucket =  var.weather_bucket_name

    tags = {
        Name = "Weather"
    }
  
}

resource "aws_s3_bucket_notification" "weather_notification" {
  bucket = aws_s3_bucket.weather_bucket.id

  queue {
    queue_arn = var.sqs_notification_arn
    events    = ["s3:ObjectCreated:*"]
  }

  depends_on = [var.sqs_notification_arn]
}


output "source_name" {
    value = var.source_bucket_name
}

output "weather_bucket_name" {
    value = var.weather_bucket_name
}

output "weather_bucket_arn" {
    value =  aws_s3_bucket.weather_bucket.arn
  
}