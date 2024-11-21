
# WeatherDataEngineering

This project is designed to process and manage weather-related data using AWS services like S3, Lambda, DynamoDB, SQS, and more. The infrastructure is managed using **Terraform**, and the data is processed by AWS Lambda functions.
This project is only intended for learning purposes

## Overview

The WeatherDataEngineering project enables the collection, processing, and storage of weather, pollution, and sensor data. The project uses AWS Lambda to process incoming data and store it in **S3**, **DynamoDB**, and **SQS** for further analysis and processing.

## Architecture

The system is built around several key AWS services:
1. **S3 Buckets**: Store raw weather and sensor data.
2. **DynamoDB**: Store metadata such as file processing status.
3. **SQS**: Used for event-driven processing of files uploaded to S3.
4. **Lambda Functions**: Process data from S3, transform it, and store the result in DynamoDB.
5. **IAM Roles**: Provide secure access to AWS resources for Lambda and other services.

The following Terraform modules and resources are used to manage the infrastructure:
- **Lambda** functions are triggered by file uploads to S3 and manage data processing.
- **IAM Policies** define the roles and permissions for various services.
- **SQS Queues** are used to manage notifications and failures in the data processing pipeline.
- **DynamoDB Tables** store metadata about processed files.

## Prerequisites

- **Terraform**: This project uses Terraform to manage infrastructure. You need Terraform installed on your local machine or CI/CD pipeline.
- **AWS Account**: The project uses AWS services, so you need an AWS account and appropriate permissions to create resources (IAM, Lambda, S3, DynamoDB, etc.).
- **AWS CLI**: Optional but useful for managing AWS resources locally.

## Getting Started

### 1. Clone the Repository

Clone the repository to your local machine:

```bash
git clone https://github.com/yourusername/WeatherDataEngineering.git
cd WeatherDataEngineering
```
### 2. Set Up Terraform

```bash
cd src/infrastructure
terraform init
```
### 3. Configure Variables
This project requires a few environment-specific variables. You can configure these
in the ```terraform.tfvars``` file or pass them directly in the command line.

### 4. Constcuct your Infrastructure
To apply infrastructure configuration, run the following command:
```bash
terraform apply
```
Terraform will prompt you to configure the changes. Type ```yes``` to proceed.



## Contributing

Feel free to fork the project, open issues, or submit pull requests. If you have ideas for improvements or additional features, open an issue to discuss.
