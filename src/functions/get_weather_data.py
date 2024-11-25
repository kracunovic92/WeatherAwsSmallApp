import boto3
import os
import csv
from io import StringIO
import logging
from datetime import datetime
from externalAPI import get_visitor_data

# Set up logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)  # Log level can be INFO, DEBUG, ERROR, etc.

s3 = boto3.client('s3')

def lambda_handler(event, context):


    source_bucket = os.environ['SOURCE_BUCKET']
    destination_bucket = os.environ['DESTINATION_BUCKET']
    folder = os.environ['SOURCE_FOLDER']
    city = os.environ['CITY_NAME']
    city_name = os.environ['CITY_NAME_SRB']
    API = os.environ['API_ENDPOINT']
    PARAM_NAME = os.environ['API_KEY']
    REGION_NAME = os.environ['REGION_NAME']

    prefix = f'{folder}/'
    #logger.info(f"Processing source bucket: {source_bucket}, destination bucket: {destination_bucket}, with prefix: {prefix}")

    try:
        paginator = s3.get_paginator('list_objects_v2')
        iterator = paginator.paginate(Bucket=source_bucket, Prefix=prefix)
        matching_folders = []

        for p in iterator:
            #logger.info(f"For p in {p}")
            if 'Contents' in p:
                for obj in p['Contents']:
                    #logger.info(f"For obj in {obj}")
                    source_key = obj['Key']
                    #logger.debug(f"Found object: {source_key}")
                    folder_part = source_key.split('/')[1]
                    if (city_name in folder_part and folder_part not in matching_folders) or (city in folder_part and folder_part not in matching_folders):
                        matching_folders.append(folder_part)
        
        if not matching_folders:
            #logger.error("No matching folders found.")
            raise ValueError("Missing folders")
        
        
        for f in matching_folders:
            prefix = f'{folder}/{f}/'

            for page in paginator.paginate(Bucket=source_bucket, Prefix=prefix):
                
                if 'Contents' in page:
                    for obj in page['Contents']:

                        file_key = obj['Key']

                        date_part = file_key.split('/')[2]
                        date_object = datetime.strptime(date_part, '%d-%m-%Y')
                        new_format = '%Y-%m-%d'
                        new_date_string = date_object.strftime(new_format)

                        external_data = get_visitor_data.get_tourist_for_day(new_date_string, API, PARAM_NAME, REGION_NAME)
                        estimated_no_people = 0
                        for val in external_data['info']:
                            
                            if val['name'].lower() == city.lower():
                                estimated_no_people = val['estimated_no_people']

                        response = s3.get_object(Bucket=source_bucket, Key=file_key)
                        file_content = response['Body'].read().decode('utf-8')

                        logger.debug(f"File content retrieved for key: {file_key}")

                        input_csv = csv.reader(file_content.splitlines())
                        header = next(input_csv)
                        logger.debug(f"CSV Header: {header}")

                        output_csv = StringIO()
                        csv_writer = csv.writer(output_csv)

                        # Write the header to the output CSV
                        header.append('tourist_data')
                        csv_writer.writerow(header)

                        # Process each row, append the required data, and write to the output
                        for row in input_csv:
                            logger.debug(f"Processing row: {row}")
                            row.append(estimated_no_people)  # Default to "N/A" if city data is missing
                            csv_writer.writerow(row)

                        enriched_data = output_csv.getvalue()
                        logger.info(f"CSV processing complete for key: {file_key}")
                        destination_key = file_key

                        logger.info(f"Destination : {destination_key}")
                        s3.put_object(
                            Bucket=destination_bucket,
                            Key=destination_key,
                            Body=enriched_data,
                            ContentType="text/csv"
                        )
                        logger.info(f"Enriched file uploaded to {destination_bucket}/{destination_key}")
                else:
                    logger.error("Missing files in folder.")
                    raise ValueError('Missing files in folder')
    except Exception as e:
        logger.error(f"Error: {e}")
        print(f'Error: {e}')
