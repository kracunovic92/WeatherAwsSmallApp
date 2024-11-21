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
    script_bucket_name = "scripts-lazars"
    procees_bucket_name = "processed-lazars"
    sqs_notification_arn = module.sqs.notification_sqs_arn
    role_arn =  module.iam.lambda_role_arn

  
}

module "iam"{

    source = "./services/iam"
    lambda_role_name = "Lambda_Role_Everything"
    s3_policy_name = "Access_to_S3_Lambda"
    s3_weather_bucket_arn = module.s3.weather_bucket_arn
    glue_role_name = "Glue_Role_Everything"
    glue_policy_name = "Access_to_S3_and_Glue"
    glue_job_arn = module.glue.job_arn
    cloudwatch_role_name = "CloudWatch_Role_Everything"
    script_bucket_arn = module.s3.script_bucket_arn
    sqs_arn = module.sqs.notification_sqs_arn
    sqs_url = module.sqs.notification_sqs_url
    
}

module "lambda" {
    source = "./services/lambda"
    lambda_role_arn = module.iam.lambda_role_arn
    lambda_role_attachment_arn = module.iam.lambda_role_attachment_arn
    s3_source_name = module.s3.source_name
    s3_target_name = module.s3.weather_bucket_name
    table_name = module.dynamo.table_name
    sqs_arn =  module.sqs.notification_sqs_arn
  
}

module "sqs" {
    source = "./services/sqs"
    bucket_name = module.s3.weather_bucket_name
    bucket_arn = module.s3.weather_bucket_arn
  
}
module "dynamo"{
    source = "./services/dynamodb"
}

module "glue_crawler" {
    source = "./services/glue_crawler"

    role_glue_arn = module.iam.glue_role_arn
    bucket_arn = module.s3.weather_bucket_arn
    bucket_name = module.s3.weather_bucket_name
    catalog_name = module.glue.catalog_name
    bucket_url = module.s3.weather_bucket_url
}
module "glue"{
    source = "./services/glue"

    catalog_name = "catalog_process"
    glue_role_arn = module.iam.glue_role_arn
    job_name = "Process_Data_Job"
    s3_script_url =  module.s3.script_bucket_url
    script_name = "process_data.py"
    source_bucket_url = module.s3.weather_bucket_url
    destination_bucket_url = module.s3.destination_bucket_url
    trigger_name = "job_trigger"
    clawler_name = module.glue_crawler.crawler_name
    glue_workflow_name = "Weather Workflow"
}

module "cloud_watch" {
    source = "./services/cloud_watch"
    glue_job_arn = module.glue.job_arn
    cloudwatch_arn = module.iam.cloudwatch_event_role_arn
    crawler_name =  module.glue_crawler.crawler_name
    completion_rule = "watch_crawler"
    glue_workflow_arn = module.glue.workflow_arn
}