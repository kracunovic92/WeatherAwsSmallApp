resource "aws_glue_catalog_database" "catalog" {
    name = var.catalog_name
  
}


resource "aws_glue_workflow" "data_processing_workflow" {
    name = var.glue_workflow_name
    description = "Workflow to orchestrate Glue tasks"
  
}


resource "aws_glue_trigger" "start-trigger" {
    name = "start-trigger"
    type = "ON_DEMAND"
    workflow_name =  aws_glue_workflow.data_processing_workflow.name

    actions {
      crawler_name = aws_glue_crawler.weather_crawler.name
    }
  
}

resource "aws_glue_crawler" "weather_crawler" {
    name = "weather_crawler"
    role = var.glue_role_arn
    database_name = var.catalog_name

    s3_target {
      path = "${var.source_bucket_url}"
    }
    
    schedule = "cron(0 0 * * ? *)"
    depends_on = [aws_glue_workflow.data_processing_workflow]
    
}


resource "aws_glue_trigger" "trigger_job" {
    name = var.trigger_name
    type = "CONDITIONAL"
    workflow_name =  aws_glue_workflow.data_processing_workflow.name

    actions {
      job_name = aws_glue_job.process_s3_data.name
    }
    
    predicate {
      conditions {
        logical_operator = "EQUALS"
        crawler_name =  aws_glue_crawler.weather_crawler.name
        crawl_state = "SUCCEEDED"
      }
    }
}



resource "aws_glue_job" "process_s3_data" {

    name = var.job_name
    role_arn = var.glue_role_arn

    command {
      name ="glueetl"
      script_location = "s3://${var.s3_script_url}/${var.script_name}"
    }

    timeout = 60
    default_arguments = {
        "--enable-metrics" = "true"
        "--catalog_database" = aws_glue_catalog_database.catalog.name
        "--catalog_tables" = join(",", var.catalog_table_names)
        "--input_data_path" = "${var.source_bucket_url}"
        "--output_data_path" = "${var.destination_bucket_url}"
    }
  
}



output "catalog_name" {
    value = aws_glue_catalog_database.catalog.name
  
}
output "catalog_arn" {
    value = aws_glue_catalog_database.catalog.arn
  
}
output "job_arn" {
    value = aws_glue_job.process_s3_data.arn
  
}
output "workflow_arn" {
    value = aws_glue_workflow.data_processing_workflow.arn
  
}

output "crawler_name"{
    value = aws_glue_crawler.weather_crawler.name
}