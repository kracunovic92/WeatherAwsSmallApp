resource "aws_dynamodb_table" "file_status_table" {

    name = var.dynamodb_table_name
    billing_mode = "PAY_PER_REQUEST"

    hash_key = "file_name"
    range_key = "timestamp"

    attribute {
      name = "file_name"
      type = "S"
    }
    attribute {
      name = "timestamp"
      type = "S"
    }
    attribute {
      name = "status"
      type = "N"

    }

    global_secondary_index {
        name               = "status-index"
        hash_key           = "status"
        projection_type    = "ALL"
        read_capacity      = 5
        write_capacity     = 5
    }
    
    tags = {
        Name = "Weather-Table"
    }

  
}


output "table_name" {
  value = var.dynamodb_table_name
  
}

output "table_arn" {

    value = aws_dynamodb_table.file_status_table.arn
  
}