import configparser
from pyspark.sql import SparkSession # type: ignore
from pyspark.sql.types import StructType, StructField, IntegerType, StringType # type: ignore


# Read AWS credentials from ~/.aws/credentials
config = configparser.ConfigParser()
config.read('/home/mapr/.aws/credentials')
aws_access_key = config['default']['accessKey']
aws_secret_key = config['default']['secretKey']

# print(f"ACCESS/SECRET KEYS {aws_access_key}:{aws_secret_key}")

# Define S3 and Iceberg paths
staging_path = "s3a://demobk/staging/"
iceberg_table = "demo.users"
iceberg_warehouse = "s3a://demobk/iceberg/"

# Create Spark session with Iceberg and S3 support
spark = SparkSession.builder \
    .appName("IcebergIngestion") \
    .config("spark.sql.catalog.demo", "org.apache.iceberg.spark.SparkCatalog") \
    .config("spark.sql.catalog.demo.type", "hadoop") \
    .config("spark.sql.catalog.demo.warehouse", iceberg_warehouse) \
    .config("spark.hadoop.fs.s3a.access.key", aws_access_key) \
    .config("spark.hadoop.fs.s3a.secret.key", aws_secret_key) \
    .config("spark.hadoop.fs.s3a.endpoint", "https://mapr.demo.:9000") \
    .config("spark.hadoop.fs.s3a.path.style.access", "true") \
    .getOrCreate()

# Define schema for the users table
schema = StructType([
    StructField("id", IntegerType(), True),
    StructField("title", StringType(), True),
    StructField("first", StringType(), True),
    StructField("last", StringType(), True),
    StructField("street", StringType(), True),
    StructField("city", StringType(), True),
    StructField("state", StringType(), True),
    StructField("postcode", StringType(), True),
    StructField("country", StringType(), True),
    StructField("gender", StringType(), True),
    StructField("email", StringType(), True),
    StructField("uuid", StringType(), True),
    StructField("username", StringType(), True),
    StructField("password", StringType(), True),
    StructField("phone", StringType(), True),
    StructField("cell", StringType(), True),
    StructField("dob", StringType(), True),
    StructField("registered", StringType(), True),
    StructField("large", StringType(), True),
    StructField("medium", StringType(), True),
    StructField("thumbnail", StringType(), True),
    StructField("nat", StringType(), True)
])

# Read Parquet files from staging path
df = spark.read.schema(schema).parquet(staging_path)

# Create Iceberg table if it doesn't exist
spark.sql(f"""
    CREATE TABLE IF NOT EXISTS {iceberg_table} (
        id INT,
        title STRING,
        first STRING,
        last STRING,
        street STRING,
        city STRING,
        state STRING,
        postcode STRING,
        country STRING,
        gender STRING,
        email STRING,
        uuid STRING,
        username STRING,
        password STRING,
        phone STRING,
        cell STRING,
        dob STRING,
        registered STRING,
        large STRING,
        medium STRING,
        thumbnail STRING,
        nat STRING
    )
    USING iceberg
""")
    # PARTITIONED BY (country)

# Append data to the Iceberg table
df.writeTo(iceberg_table).append()

# Stop the Spark session
spark.stop()
