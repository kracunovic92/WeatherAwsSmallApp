

variable "sqs_notification_name" {
    
    type = string
    nullable = false
    default = "sqs_notification"
  
}

variable "sqs_deadq_name" {
  
  type = string
  nullable = false
  default = "sqs_deadq"


}

variable "bucket_name" {
  type = string
  nullable = false
  
}
variable "bucket_arn" {
  type = string
  nullable = false
}

variable "sqs_write_name" {
  type = string
  nullable = false
  
}