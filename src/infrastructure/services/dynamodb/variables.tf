

variable "dynamodb_table_name" {
    type = string
    nullable = false
    default = "WeatherTable"
  
}

output "table_name" {

    value = var.dynamodb_table_name
  
}