

resource "aws_glue_crawler" "weather_crawler" {
    name = "weather_crawler"
    role = var.role_glue_arn
    database_name = var.catalog_name

    s3_target {
      path = "${var.bucket_url}"
    }
    
    schedule = "cron(0 0 * * ? *)"
}


output "crawler_arn" {

    value = aws_glue_crawler.weather_crawler.arn
  
}
output "crawler_name" {
  value = aws_glue_crawler.weather_crawler.name
  
}



