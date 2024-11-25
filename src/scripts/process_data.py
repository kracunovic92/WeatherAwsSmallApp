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

# Define data types as an Enum
class DataType(Enum):
    WEATHER = "weather"
    POLLUTION = "pollution"
    SENSOR = "sensor"

# Initialize Glue Context
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session

# Parse input arguments
args = getResolvedOptions(sys.argv, [
    "JOB_NAME",
    "data_type",
    "input_data_path",
    "output_data_path"
])

data_type = args["data_type"]
input_path = args["input_data_path"]
output_path = args["output_data_path"]

# Process weather data
def process_weather_data():
    schema = StructType([
        StructField("name", StringType(), True),
        StructField("time_nano", StringType(), True),
        StructField("time_date", TimestampType(), True),
        StructField("location_latitude", FloatType(), True),
        StructField("location_longitude", FloatType(), True),
        StructField("weather_temperature", FloatType(), True),
        StructField("weather_pressure", FloatType(), True),
        StructField("weather_humidity", FloatType(), True),
        StructField("weather_windSpeed", FloatType(), True),
        StructField("weather_clouds", FloatType(), True)
    ])

    # Read CSV data
    df = spark.read.schema(schema).csv(input_path, header=True)

    # Convert time_nano to timestamp and create partition column
    df = df.withColumn("time_nano", (F.col("time_nano").cast("bigint") / 1000000).cast(TimestampType()))
    df = df.withColumn("partition_date", F.to_date("time_date"))

    # Write partitioned data to S3
    write_data_to_s3(df)

# Process pollution data
def process_pollution_data():
    schema = StructType([
        StructField("name", StringType(), True),
        StructField("time_nano", StringType(), True),
        StructField("time_date", TimestampType(), True),
        StructField("location_latitude", FloatType(), True),
        StructField("location_longitude", FloatType(), True),
        StructField("measurement_pm10Atmo", FloatType(), True),
        StructField("measurement_pm25Atmo", FloatType(), True),
        StructField("measurement_pm100Atmo", FloatType(), True)
    ])

    # Read CSV data
    df = spark.read.schema(schema).csv(input_path, header=True)

    # Convert time_nano to timestamp and create partition column
    df = df.withColumn("time_nano", (F.col("time_nano").cast("bigint") / 1000000).cast(TimestampType()))
    df = df.withColumn("partition_date", F.to_date("time_date"))

    # Write partitioned data to S3
    write_data_to_s3(df)

# Process sensor data
def process_sensor_data():
    schema = StructType([
        StructField("time_nano", StringType(), True),
        StructField("location_latitude", FloatType(), True),
        StructField("location_longitude", FloatType(), True),
        StructField("location_name", StringType(), True),
        StructField("name", StringType(), True),
        StructField("pms7003Measurement_pm10Atmo", FloatType(), True),
        StructField("pms7003Measurement_pm25Atmo", FloatType(), True),
        StructField("pms7003Measurement_pm100Atmo", FloatType(), True)
    ])

    # Read CSV data
    df = spark.read.schema(schema).csv(input_path, header=True)

    # Convert time_nano to timestamp and create partition column
    df = df.withColumn("time_nano", (F.col("time_nano").cast("bigint") / 1000000).cast(TimestampType()))
    df = df.withColumn("partition_date", F.to_date("time_nano"))

    # Write partitioned data to S3
    write_data_to_s3(df)

# Generic function to write partitioned data to S3
def write_data_to_s3(df):
    # Convert DataFrame to DynamicFrame
    dynamic_frame = DynamicFrame.fromDF(df, glueContext, "dynamic_frame")

    # Write partitioned data to S3 as Parquet
    dynamic_frame.toDF().write.partitionBy("partition_date").parquet(output_path)
    print(f"Data written to {output_path}")

# Main function to process data based on data type
if __name__ == "__main__":
    print(f"Starting Glue job for data type: {data_type}")
    job = Job(glueContext)
    job.init(args["JOB_NAME"], args)

    if data_type == DataType.WEATHER.value:
        process_weather_data()
    elif data_type == DataType.POLLUTION.value:
        process_pollution_data()
    elif data_type == DataType.SENSOR.value:
        process_sensor_data()
    else:
        raise ValueError(f"Unsupported data type: {data_type}")

    job.commit()
