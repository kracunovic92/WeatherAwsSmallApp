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
            "s3:ListBucket",
            ]
            Resource = "*"#["${var.s3_weather_bucket_arn}", "${var.s3_start_data_arn}"]
        }
        ]
    })
  
}

resource "aws_iam_policy" "lambda_dynamodb_policy" {
  name        = "lambda-dynamodb-policy"
  description = "Allow Lambda to write data to DynamoDB"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:GetItem",
          "dynamodb:BatchWriteItem",
          "dynamodb:BatchGetItem"
        ],
        Resource = "${var.dynamodb_table_arn}"
      }
    ]
  })
}




resource "aws_iam_policy" "glue_policy" {
  name        = "glue-policy"
  description = "Policy for Glue to access resources"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement: [
      {
        Effect: "Allow",
        Action: [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ],
        Resource: [
          "*"
        ]
      },
      {
        Effect: "Allow",
        Action: [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource: "arn:aws:logs:*:*:*"
      },
      {
        Effect: "Allow",
        Action: [
          "glue:*"
        ],
        Resource: "*"
      }
    ]
  })
}


resource "aws_iam_role_policy" "cloudwatch_event_policy" {
  name   = "cloudwatch-event-policy"
  role   = aws_iam_role.cloudwatch_event_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "glue:StartJobRun",
        Effect    = "Allow",
        Resource  = ["${var.glue_job_arn}"]
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_sqs_policy" {
  name        = "lambda-sqs-policy"
  description = "Allow Lambda to interact with SQS"
  policy =  data.aws_iam_policy_document.lambda_sqs_policy.json
}


data "aws_iam_policy_document" "lambda_sqs_policy" {
  statement {
    actions   = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"]
    resources = ["${var.sqs_arn}"]
  }

  statement {
    actions   = ["logs:*", "cloudwatch:*"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "lambda_secrets_policy" {
  name = "lambda_secrets_policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["secretsmanager:GetSecretValue"],
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"],
        Resource = "*"
      }
    ]
  })
}


resource "aws_iam_policy" "glue_logs_policy" {
  name        = "glue-logs-policy"
  description = "Policy for Glue to write logs to CloudWatch"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*"
      }
    ]
  })
}

