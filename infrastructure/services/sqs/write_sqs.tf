resource "aws_sqs_queue" "write_que" {

    name = var.sqs_write_name
    visibility_timeout_seconds = 900


}

resource "aws_sqs_queue_policy" "write_policy" {
    queue_url =  aws_sqs_queue.write_que.id
    policy = data.aws_iam_policy_document.queue.json
  
}

output "write_sqs_queue_name" {
    value = aws_sqs_queue.write_que.name
  
}
output "write_sqs_queue_arn" {
  value = aws_sqs_queue.write_que.arn
}
output "write_sqs_queue_url" {

    value = aws_sqs_queue.write_que.id
  
}