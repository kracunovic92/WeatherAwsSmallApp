

# resource "aws_lambda_function" "get_data_from_source_bucket" {
#     for_each =  var.lambda_configs
#     filename = data.archive_file.lambda_zip[each.key].output_path
#     function_name = each.key
#     role = var.lambda_role_arn
#     handler = "get_weather_data.lambda_handler"
#     runtime = "python3.13"
#     depends_on = [ var.lambda_role_attachment_arn , aws_lambda_layer_version.external_API]

#     layers = [
#       aws_lambda_layer_version.external_API.arn
#     ]
#     timeout = 900
#     environment {
#       variables = {

#       }
#     }
  
# }

resource "aws_lambda_function" "put_weather_dynamo" {

  filename = data.archive_file.lambda_sqs_zip.output_path
  function_name = "put_weather_dynamo"
  role = var.lambda_role_arn
  handler = "put_weather_dynamo.lambda_handler"
  runtime = "python3.13"
  depends_on = [ var.lambda_role_attachment_arn ]
  environment {
    variables = {
      DYNAMODB_TABLE_NAME = var.table_name
    }
  }

}

resource "aws_lambda_function" "select_and_que" {
  
  filename = data.archive_file.lambda_select_and_que.output_path
  function_name = "select_and_que"
  role = var.lambda_role_arn
  handler = "select_and_que.lambda_handler"
  runtime = "python3.13"
  depends_on = [ var.lambda_role_attachment_arn ]
  timeout = 900
  environment {
    variables = {
        SOURCE_BUCKET = var.s3_source_name
        CITY_NAME = var.city
        CITY_NAME_SRB = var.city_srb
        SQS_QUEUE_URL = var.write_sqs_url

    }
  }
  
}

resource "aws_lambda_function" "enrich_and_copy" {
  filename = data.archive_file.lambda_enrich_and_copy.output_path
  function_name = "enrich_and_copy"
  role = var.lambda_role_arn
  handler = "enrich_and_copy.lambda_handler"
  runtime = "python3.13"
  depends_on = [var.lambda_role_attachment_arn, aws_lambda_layer_version.external_API] 
  layers = [
       aws_lambda_layer_version.external_API.arn
     ]
  timeout = 900
  environment {
    variables = {
      SOURCE_BUCKET = var.s3_source_name
      DESTINATION_BUCKET = var.s3_target_name
      SOURCE_FOLDER = join(",",var.source_folders)
      API_ENDPOINT = var.API_ENDPOINT
      API_KEY = var.API_KEY
      REGION_NAME = var.REGION_NAME
      CITY_NAME = var.city
      CITY_NAME_SRB = var.city_srb

    }
  }
  
}





