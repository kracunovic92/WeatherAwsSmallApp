variable "catalog_name" {
    type = string
    nullable = false
  
}

variable "job_name" {
    type = string
    nullable = false
  
}

variable "glue_role_arn" {
    type = string
    nullable = false
  
}

variable "s3_script_url" {
    type = string
    nullable = false
}

variable "script_name" {
    type = string
    nullable = false    
  
}

variable "source_bucket_url" {
  type = string
  nullable = false
}

variable "destination_bucket_url" {
  type = string
  nullable = false
}

variable "glue_workflow_name" {
    type = string
    nullable = false
  
}
variable "trigger_name" {
    type = string
    nullable = false
}


variable "catalog_table_names" {
    type = list(string)
    default = [ "pollution", "sensor", "weather"]
  
}