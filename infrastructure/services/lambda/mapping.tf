
resource "aws_lambda_event_source_mapping" "get_trigger" {

    event_source_arn = var.sqs_write_arn
    function_name =  aws_lambda_function.enrich_and_copy.arn
    enabled = true
    batch_size = 10
  
}

resource "aws_lambda_event_source_mapping" "sqs_trigger" {

  event_source_arn = var.sqs_arn
  function_name = aws_lambda_function.put_weather_dynamo.arn
  enabled = true
  batch_size = 10
  
}