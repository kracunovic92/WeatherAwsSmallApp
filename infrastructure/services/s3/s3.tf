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

resource "aws_s3_bucket" "processed_data" {
  bucket = var.procees_bucket_name

  tags = {
    Name = "Finalized Data"
  }
  
}
resource "aws_s3_bucket" "weather_bucket" {

    bucket =  var.weather_bucket_name

    tags = {
        Name = "Weather"
    }
  
}

resource "aws_s3_bucket" "script_bucket" {

  bucket = var.script_bucket_name
  tags = {
    Name = "Script"
  }
  
}
resource "aws_s3_object" "proccess_data_script" {
  bucket = aws_s3_bucket.script_bucket.bucket
  key = "process_data.py"
  source = "${path.root}/../src/scripts/process_data.py"
  
}

resource "aws_s3_bucket_notification" "weather_notification" {
  bucket = aws_s3_bucket.weather_bucket.id

  queue {
    queue_arn = var.sqs_notification_arn
    events    = ["s3:ObjectCreated:*"]
  }

  depends_on = [var.sqs_notification_arn]
}

output "script_bucket_url" {
  value = aws_s3_bucket.script_bucket.id
  
}
output "script_bucket_arn" {
  value = aws_s3_bucket.script_bucket.arn
  
}
output "destination_bucket_url" {
  value = aws_s3_bucket.processed_data.id
  
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
output "weather_bucket_url" {
  value = aws_s3_bucket.weather_bucket.id
  
}