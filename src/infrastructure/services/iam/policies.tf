resource "aws_iam_policy" "s3_policy" {

    name = var.s3_policy_name
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
        {
            Effect = "Allow"
            Action = [
            "s3:PutObject",
            "s3:GetObject",
            "s3:ListBucket"
            ]
            Resource = [var.s3_weather_bucket_name]
        }
        ]
    })
  
}



