
### GLUE ATTATCHMENT ####
resource "aws_iam_role_policy_attachment" "glue_role_attachment" {
    role = aws_iam_role.glue_role.name
    policy_arn = aws_iam_policy.glue_policy.arn
  
}
resource "aws_iam_role_policy_attachment" "glue_logs_policy_attachment" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.glue_logs_policy.arn
}


#### LAMBDA ATTACHMENT ####
resource "aws_iam_role_policy_attachment" "lambda_sqs_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_sqs_policy.arn
}
resource "aws_iam_role_policy_attachment" "attach_lambda_secrets_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_secrets_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_dynamodb_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_role_attachment" {

    role = aws_iam_role.lambda_role.name
    policy_arn = aws_iam_policy.s3_policy.arn
  
}



output "lambda_role_attachment_arn" {
    value = aws_iam_role_policy_attachment.lambda_role_attachment.policy_arn
  
}
output "glue_role_attachment_arn" {
    value = aws_iam_role_policy_attachment.glue_role_attachment.policy_arn
  
}
output "lambda_sqs_policy_attachment" {
    value =  aws_iam_role_policy_attachment.lambda_sqs_policy_attachment.policy_arn
  
}


