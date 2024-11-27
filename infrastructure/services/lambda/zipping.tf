data "archive_file" "api_layer_zip"{
  type = "zip"
  source_dir = "${path.root}/../src/externalAPI/"
  output_path = "${path.root}/../src/externalAPI/externalAPI.zip"
}

data "archive_file" "lambda_sqs_zip"{

  type = "zip"
  source_file = "${path.root}/../src/functions/put_weather_dynamo.py"
  output_path = "${path.root}/../src/functions/zipped/put_weather_dynamo.zip"
}

data "archive_file" "lambda_enrich_and_copy"{
  type = "zip"
  source_file = "${path.root}/../src/functions/enrich_and_copy.py"
  output_path =  "${path.root}/../src/functions/zipped/enrich_and_copy.zip"
}

data "archive_file" "lambda_select_and_que"{
  
  type = "zip"
  source_file = "${path.root}/../src/functions/select_and_que.py"
  output_path = "${path.root}/../src/functions/zipped/select_and_que.zip"
}
