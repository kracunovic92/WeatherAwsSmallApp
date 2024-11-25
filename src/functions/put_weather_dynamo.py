import boto3
import json
import os
from datetime import datetime
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

dynamodb = boto3.resource('dynamodb')
table =dynamodb.Table(os.environ['DYNAMODB_TABLE_NAME'])


def lambda_handler(event, context):


    for record in event['Records']:

        sqs_message = json.loads(record['body'])
        s3_event =sqs_message['Records'][0]


        key = s3_event['s3']['object']['key']
        logger.info(f'Evnet key = {key}')

        if key.startswith(('pollution/','sensor/','weather')):

            logger.info(f"Starting {key}")

            table.put_item(
                Item = {
                    'file_name': key.split('/')[-1],
                    'timestamp': datetime.now().isoformat(),
                    'status': 0
                }
            )
            logger.info(f'Table info {table}')
    
    return {'statusCode': 200}