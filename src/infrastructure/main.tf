provider "aws" {

    region = "eu-north-1"
    access_key = var.aws_public_token
    secret_key = var.aws_secret_token
    token =  var.aws_session_token
  
}

module "s3" {
    source = "./services/s3"
    source_bucket_name = "nine-air-weather-data"
    weather_bucket_name = "weather-lazars"
    sqs_notification_arn = module.sqs.notification_sqs_arn
    role_arn =  module.iam.lambda_role_arn
  
}

module "iam"{

    source = "./services/iam"
    lambda_role_name = "Lambda_Role_Everything"
    s3_policy_name = "Access_to_S3_Lambda"
    s3_weather_bucket_name = module.s3.weather_bucket_arn
}

module "lambda" {
    source = "./services/lambda"
    lambda_role_arn = module.iam.lambda_role_arn
    lambda_role_attachment_arn = module.iam.lambda_role_attachment_arn
    s3_source_name = module.s3.source_name
    s3_target_name = module.s3.weather_bucket_name
    table_name = module.dynamo.table_name
  
}

module "sqs" {
    source = "./services/sqs"
    bucket_name = module.s3.weather_bucket_name
    bucket_arn = module.s3.weather_bucket_arn
  
}
module "dynamo"{
    source = "./services/dynamodb"
}