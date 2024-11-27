import sys
import boto3
from enum import Enum
from awsglue.context import GlueContext
from awsglue.dynamicframe import DynamicFrame
from pyspark.context import SparkContext
from pyspark.sql import functions as F
from pyspark.sql.types import StructType, StructField, StringType, FloatType, TimestampType
from awsglue.utils import getResolvedOptions
from awsglue.job import Job


class DataType(Enum):
    WEATHER = "weather"
    POLLUTION = "pollution"
    SENSOR = "sensor"


sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session

args = getResolvedOptions(sys.argv, [
    "JOB_NAME",
    "catalog_database",
    "catalog_tables",
    "output_data_path"
])

data_type = args["data_type"]
catalog_database = args["catalog_database"]
catalog_tables = args["catalog_tables"].split(",")
output_path = args["output_data_path"]



def process_table(table_name):
    # Read data from the Glue Data Catalog
    dynamic_frame = glueContext.create_dynamic_frame.from_catalog(
        database=catalog_database,
        table_name=table_name
    )
    df = dynamic_frame.toDF()

    # Perform data processing
    df = df.withColumn("processed_date", F.current_date())

    # Write the data to the output path partitioned by table name
    output_table_path = f"{output_path}/{table_name}"
    df.write.mode("overwrite").parquet(output_table_path)
    print(f"Processed and saved data for table: {table_name}")



if __name__ == "__main__":
    print(f"Starting Glue job for data type: {data_type}")
    job = Job(glueContext)
    job.init(args["JOB_NAME"], args)

    for table in catalog_tables:

        process_table(table)

    job.commit()
