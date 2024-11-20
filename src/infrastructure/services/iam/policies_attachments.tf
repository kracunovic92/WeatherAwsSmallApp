resource "aws_iam_role_policy_attachment" "lambda_role_attachment" {

    role = aws_iam_role.lambda_role.name
    policy_arn = aws_iam_policy.s3_policy.arn
  
}


output "lambda_role_attachment_arn" {
    value = aws_iam_role_policy_attachment.lambda_role_attachment.policy_arn
  
}