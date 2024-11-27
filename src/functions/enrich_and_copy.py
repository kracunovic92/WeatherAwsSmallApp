import boto3
import os
import csv
from io import StringIO
import logging
from datetime import datetime
from externalAPI import get_visitor_data

# Set up logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# AWS Clients
s3 = boto3.client('s3')
sqs = boto3.client('sqs')

def lambda_handler(event, context):
    """
    Processes a single object from SQS, enriches its data by calling an external API,
    and writes the enriched CSV back to a destination S3 bucket.
    """
    destination_bucket = os.environ['DESTINATION_BUCKET']
    API = os.environ['API_ENDPOINT']
    PARAM_NAME = os.environ['API_KEY']
    REGION_NAME = os.environ['REGION_NAME']
    city = os.environ['CITY_NAME']

    try:
        # Iterate over records (in case there are multiple messages in the batch)
        for record in event['Records']:
            # Get SQS message body (expected to be the S3 object key)
            file_key = record['body']  # Assume the message body contains the full S3 key
            source_bucket = os.environ['SOURCE_BUCKET']

            logger.info(f"Processing file: {file_key} from bucket: {source_bucket}")

            # Retrieve the file from S3
            response = s3.get_object(Bucket=source_bucket, Key=file_key)
            file_content = response['Body'].read().decode('utf-8')

            # Extract date from file key (assuming a fixed format)
            date_part = file_key.split('/')[2]  # Adjust if file key format differs
            date_object = datetime.strptime(date_part, '%d-%m-%Y')
            new_date_string = date_object.strftime('%Y-%m-%d')

            # Get external tourist data for the specific date
            external_data = get_visitor_data.get_tourist_for_day(new_date_string, API, PARAM_NAME, REGION_NAME)
            estimated_no_people = 0
            for val in external_data['info']:
                if val['name'].lower() == city.lower():
                    estimated_no_people = val['estimated_no_people']

            # Process CSV file
            input_csv = csv.reader(file_content.splitlines())
            header = next(input_csv)
            output_csv = StringIO()
            csv_writer = csv.writer(output_csv)

            # Add the new column header for tourist data
            header.append('tourist_data')
            csv_writer.writerow(header)

            # Add the tourist data to each row of the CSV
            for row in input_csv:
                row.append(estimated_no_people)  # Append tourist data
                csv_writer.writerow(row)

            enriched_data = output_csv.getvalue()

            # Upload the enriched CSV back to the destination S3 bucket
            destination_key = file_key  # Use the same key in the destination bucket
            s3.put_object(
                Bucket=destination_bucket,
                Key=destination_key,
                Body=enriched_data,
                ContentType="text/csv"
            )
            logger.info(f"Enriched file uploaded to {destination_bucket}/{destination_key}")

            # Delete the message from the SQS queue (to prevent reprocessing)
            receipt_handle = record['receiptHandle']
            queue_url = os.environ['QUEUE_URL']  # Ensure this is set in your environment variables
            sqs.delete_message(QueueUrl=queue_url, ReceiptHandle=receipt_handle)
            logger.info(f"Message deleted from queue: {queue_url}")

    except Exception as e:
        logger.error(f"Error processing file: {e}")
        raise ValueError(f"Error enriching data and writing to S3: {e}")
