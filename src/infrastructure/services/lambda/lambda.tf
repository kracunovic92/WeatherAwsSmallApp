
resource "aws_lambda_function" "get_data_from_source_bucket" {
    for_each =  var.lambda_configs
    filename = data.archive_file.lambda_zip[each.key].output_path
    function_name = each.key
    role = var.lambda_role_arn
    handler = "get_weather_data.event_handler"
    runtime = "python3.13"
    depends_on = [ var.lambda_role_attachment_arn ]
    environment {
      variables = {
        SOURCE_BUCKET = var.s3_source_name
        DESTINATION_BUCKET = var.s3_target_name

        SOURCE_FOLDER = each.value.source_folder
        CITY = var.city
        CITY_NAME_SRB = var.city_srb
      }
    }
  
}

resource "aws_lambda_function" "put_weather_dynamo" {

  filename = data.archive_file.lambda_sqs_zip.output_path
  function_name = "put_weather_dynamo"
  role = var.lambda_role_arn
  handler = "put_weather_dynamo.event_handler"
  runtime = "python3.13"
  depends_on = [ var.lambda_role_attachment_arn ]
  environment {
    variables = {
      DYNAMODB_TABLE_NAME = var.table_name
    }
  }
}



data "archive_file" "lambda_zip"{
    for_each = var.lambda_configs
    type = "zip"
    source_file = "${path.root}/../functions/get_weather_data.py"
    output_path = "${path.root}/../functions/zipped/${each.key}.zip"
}

data "archive_file" "lambda_sqs_zip"{

  type = "zip"
  source_file = "${path.root}/../functions/put_weather_dynamo.py"
  output_path = "${path.root}/../functions/zipped/put_weather_dynamo.zip"
}
