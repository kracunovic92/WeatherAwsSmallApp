import requests
import os
import boto3
from datetime import datetime
from dotenv import load_dotenv
import json
load_dotenv()


def __get_api_token(params, region_name):
    '''
        Getting key from Parameter store under given region
    '''

    ssm = boto3.client('secretsmanager', region_name = region_name)
    
    try:
        response = ssm.get_secret_value(SecretId=params)

        if "SecretString" in response:
            secret = response["SecretString"]
            return json.loads(secret)
        else:
            secret = response["SecretBinary"]
            return secret
    except Exception as e:
        raise f"Error while getting secret key: {e}"

def get_tourist_for_day(date : str) -> requests.Response:
    '''
        Functions that gets tourist data from external API for given date:
        Request:
            {
                date: format( YYYY-MM-DD)
            }

        Response:
            {
            "for_date": String,
            "info": List[CityEstimates]
            }

            CityEstimates:
            {
            "name": String,
            "estimated_no_people": Int
            } 
    '''
    API = os.getenv('API_ENDPOINT')
    PARAM_NAME = os.getenv('KEY_API')
    REGION_NAME = os.getenv("KEY_REGION")

    token = __get_api_token(PARAM_NAME,REGION_NAME)
    header = {
        'Authorization': f'Bearer {token[PARAM_NAME]}'
    }
    params = {
        'date': datetime.strftime(datetime.strptime(date, "%Y-%m-%d"), "%Y-%m-%d")
    }
    response =  requests.get(API,headers=header, params=params)
    
    if response.status_code == 200:
        return response.json()
    else:
        response.raise_for_status()