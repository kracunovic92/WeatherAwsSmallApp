
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
    default = "Serbia"
}
variable "city_srb" {
    type = string
    default = "Srbija"
  
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