import boto3
import json
import os
from datetime import datetime

dynamodb = boto3.resource('dynamodb')
table =dynamodb.Table(os.environ['DYNAMODB_TABLE_NAME'])


def lambda_handler(event, context):


    for record in event['Records']:

        sqs_message = json.loads(record['body'])
        s3_event =sqs_message['Records'][0]


        key = s3_event['s3']['object']['key']

        if key.startswith(('pollution/','sensor/','weather')):

            table.put_item(
                Item = {
                    'file_name': key.split('/')[-1],
                    'timestamp': datetime.now().isoformat(),
                    'status': 0
                }
            )
    
    return {'statusCode': 200}