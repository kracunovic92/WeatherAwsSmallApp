import boto3
import os

s3 = boto3.client('s3')

def lambda_handler(event, context):

    source_bucket = os.environ['SOURCE_BUCKET']
    destination_bucket = os.environ['DESTINATION_BUCKET']

    folder = os.environ['SOURCE_FOLDER']
    city = os.environ['CITY_NAME']
    city_name = os.environ['CITY_NAME_SRB']

    prefix = f'{folder}/'


    try:
        paginator = s3.get_paginator('list_objects_v2')
        iterator = paginator.paginate(Bucket= source_bucket, Prefix = prefix)
        matching_folders = []

        for p in iterator:

            if 'Contents' in p:
                for obj in p['Contents']:
                    source_key = obj['Key']
                    
                    folder_part = source_key.split('/')[1]
                    if (city_name in folder_part and folder_part not in matching_folders) or (city in folder_part and folder_part not in matching_folders):
                        matching_folders.append(folder_part)

        if not matching_folders:
            raise ValueError("Missing folders")
        
        for f in matching_folders:
            prefix=f'{folder}/{f}/'

            for page in paginator.paginate(Bucket = source_bucket, Prefix = prefix):

                if 'Contents' in page:
                    for obj in page['Contents']:

                        file_key = obj['Key']
                        destination_key = file_key
                        s3.copy_object(
                            Bucket = destination_bucket,
                            CopySource = {
                                'Bucket': source_bucket,
                                'Key': file_key
                            },
                            Key = destination_key
                        )
                else:
                    raise ValueError('Missing files in folder')
    except Exception as e:
        print(f'Error: {e}')