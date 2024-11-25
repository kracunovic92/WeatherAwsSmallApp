

resource "aws_lambda_function" "get_data_from_source_bucket" {
    for_each =  var.lambda_configs
    filename = data.archive_file.lambda_zip[each.key].output_path
    function_name = each.key
    role = var.lambda_role_arn
    handler = "get_weather_data.lambda_handler"
    runtime = "python3.13"
    depends_on = [ var.lambda_role_attachment_arn , aws_lambda_layer_version.external_API]

    layers = [
      aws_lambda_layer_version.external_API.arn
    ]
    timeout = 900
    environment {
      variables = {
        SOURCE_BUCKET = var.s3_source_name
        DESTINATION_BUCKET = var.s3_target_name

        SOURCE_FOLDER = each.value.source_folder
        CITY_NAME = var.city
        CITY_NAME_SRB = var.city_srb
        API_ENDPOINT = var.API_ENDPOINT
        API_KEY = var.API_KEY
        REGION_NAME = var.REGION_NAME
      }
    }
  
}

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

resource "aws_lambda_event_source_mapping" "sqs_trigger" {

  event_source_arn = var.sqs_arn
  function_name = aws_lambda_function.put_weather_dynamo.arn
  enabled = true
  batch_size = 10
  
}

resource "aws_lambda_layer_version" "external_API" {
  layer_name = "externalAPI"
  filename = "${path.root}/../src/externalAPI/externalAPI.zip"
  source_code_hash = filebase64sha256(data.archive_file.api_layer_zip.output_path)
  compatible_runtimes = ["python3.13"]
  depends_on = [ data.archive_file.api_layer_zip ]
}


data "archive_file" "api_layer_zip"{
  type = "zip"
  source_dir = "${path.root}/../src/externalAPI/"
  output_path = "${path.root}/../src/externalAPI/externalAPI.zip"
}


data "archive_file" "lambda_zip"{
    for_each = var.lambda_configs
    type = "zip"
    source_file = "${path.root}/../src/functions/get_weather_data.py"
    output_path = "${path.root}/../src/functions/zipped/${each.key}.zip"
}


data "archive_file" "lambda_sqs_zip"{

  type = "zip"
  source_file = "${path.root}/../src/functions/put_weather_dynamo.py"
  output_path = "${path.root}/../src/functions/zipped/put_weather_dynamo.zip"
}
