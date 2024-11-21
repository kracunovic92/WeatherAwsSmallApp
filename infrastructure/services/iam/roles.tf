resource "aws_iam_role" "lambda_role" {

    name = var.lambda_role_name
    assume_role_policy =  jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            Effect = "Allow"
            Principal = {
            Service = "lambda.amazonaws.com"
            }
            Action = "sts:AssumeRole"
        }
        ]   
    })
  
}
resource "aws_iam_role" "glue_role" {
  name  = var.glue_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role" "cloudwatch_event_role" {
  name               = var.cloudwatch_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          Service = "events.amazonaws.com"
        }
      }
    ]
  })
}

output "glue_role_arn" {
    value = aws_iam_role.glue_role.arn
    description = "The Role im using to manage Glue access"  
}


output "lambda_role_arn" {

    value = aws_iam_role.lambda_role.arn
    description = "The Role im using to manage Lambda access"
  
}
output "cloudwatch_event_role_arn" {
  value = aws_iam_role.cloudwatch_event_role.arn
  
}