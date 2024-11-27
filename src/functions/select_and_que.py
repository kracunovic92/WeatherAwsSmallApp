import boto3
import os
import csv
from io import StringIO
import logging
from datetime import datetime

# Set up logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)  # Log level can be INFO, DEBUG, ERROR, etc.

# AWS Clients
s3 = boto3.client('s3')
sqs = boto3.client('sqs')

def lambda_handler(event, context):
    """
    Selects the folders based on the provided conditions and pushes them to an SQS queue.
    """
    source_bucket = os.environ['SOURCE_BUCKET']
    city = os.environ['CITY_NAME']
    city_name = os.environ['CITY_NAME_SRB']

    matching_folders = []

    try:
        paginator = s3.get_paginator('list_objects_v2')
        iterator = paginator.paginate(Bucket=source_bucket)

        for p in iterator:
            if 'Contents' in p:
                for obj in p['Contents']:
                    source_key = obj['Key']
                    folder_part = source_key.split('/')[1]
                    if (city_name in folder_part) or \
                            (city in folder_part):
                        matching_folders.append(source_key)

        if not matching_folders:
            raise ValueError("Missing folders")

        # Push folders to SQS Queue (or DB)
        queue_url = os.environ['SQS_QUEUE_URL']
        for folder in matching_folders:
            sqs.send_message(
                QueueUrl=queue_url,
                MessageBody=folder
            )
            logger.info(f"Folder {folder} pushed to queue.")
    except Exception as e:
        logger.error(f"Error: {e}")
        raise ValueError(f"Error selecting folders: {e}")