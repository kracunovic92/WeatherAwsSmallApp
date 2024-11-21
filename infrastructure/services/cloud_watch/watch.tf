resource "aws_cloudwatch_event_rule" "crawler_completion_rule" {

    name = var.completion_rule
    description = "Trigger Glue job afer crawler completes"

    event_pattern = jsonencode({
        source = ["aws.glue"],
        detail_type = ["Glue Crawler State Change"],
        detail = {
        crawlerName = ["${var.crawler_name}"], 
        state = ["SUCCEEDED"]
        }
    })

  
}
resource "aws_cloudwatch_event_target" "trigger_glue_workflow" {

    rule = aws_cloudwatch_event_rule.crawler_completion_rule.name
    arn = var.glue_workflow_arn
    role_arn = var.cloudwatch_arn
}