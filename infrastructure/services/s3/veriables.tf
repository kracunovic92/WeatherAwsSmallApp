variable "source_bucket_name" {
    type = string
    nullable = false
  
}

variable "weather_bucket_name" {
    type = string
    nullable = false
  
}



variable "sqs_notification_arn" {
    description = "Targeting notification Queue"
    type= string
    nullable = false
}

variable "role_arn" {
    description = "Role id"
    type = string
    nullable = false
  
}

variable script_bucket_name{
    type = string
    nullable = false
}

variable "procees_bucket_name" {
    type = string
    nullable = false
  
}

