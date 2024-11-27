
variable "lambda_role_arn" {
    type = string
    description = "Role for managing Lambda Access"
  
}

variable "lambda_role_attachment_arn" {
    type =  string
    description = "Attachemt for Lambda and Role"
  
}

variable "s3_source_name" {
    type = string
    description = "Name of S3 bucket from which we are taking data into out project"
  
}

variable "s3_target_name" {
    type = string
    description = "Name of S3 bucket in which we are putting our data into"
}

variable "city"{
    type = string
    default = "Belgrade"
}
variable "city_srb" {
    type = string
    default = "Beograd"
  
}
variable "sqs_write_arn" {
    type = string
    nullable = false
  
}

variable "table_name" {
    type = string
    nullable = false
  
}


variable "lambda_configs" {

    type = map(object({
        source_folder = string
    }))
    default = {
    "get_pollution_data" = {
        source_folder = "pollution"
    }
    "get_sensor_data" = {
        source_folder = "sensor"
    }
    "get_weather_data" = {
        source_folder = "weather"
    }
    }
  
}

variable "sqs_arn" {
    type = string
    nullable = false
  
}
variable "write_sqs_url" {
    type = string
    nullable = false
  
}

variable "API_ENDPOINT" {
    type = string
    nullable = false
  
}
variable "API_KEY" {
    type = string
    nullable = false
  
}

variable "REGION_NAME" {
    type = string
    nullable = false
  
}
variable "source_folders" {
    type = list(string)
    default = [ "pollution", "sensor", "weather"]
  
}