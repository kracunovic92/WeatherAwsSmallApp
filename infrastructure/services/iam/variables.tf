variable "lambda_role_name"{
    type = string
    nullable = false
}

variable "s3_policy_name" {
    type = string
    nullable = false
  
}


variable "s3_weather_bucket_arn" {

    type = string
    nullable = false
  
}

variable "glue_role_name" {
    type = string
    nullable = false
  
}
variable "glue_policy_name" {
    type = string
    nullable = false
  
}

variable "glue_job_arn" {
    type = string
    nullable = false
  
}

variable "cloudwatch_role_name" {
    type = string
    nullable = false
  
}
variable "script_bucket_arn" {
  type = string
  nullable = false
}

variable "sqs_arn" {
    type = string
    nullable = false
  
}
variable "sqs_url" {
    type = string
    nullable = false
  
}