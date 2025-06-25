from pyspark.sql import SparkSession
import pyarrow.parquet as pq

# CATALOG_WAREHOUSE=s3://warehouse/
# CATALOG_IO__IMPL=org.apache.iceberg.aws.s3.S3FileIO
# CATALOG_S3_ENDPOINT=http://minio:9000

# from pyspark.sql.types import DoubleType, FloatType, LongType, StructType,StructField, StringType
# schema = StructType([
#   StructField("vendor_id", LongType(), True),
#   StructField("trip_id", LongType(), True),
#   StructField("trip_distance", FloatType(), True),
#   StructField("fare_amount", DoubleType(), True),
#   StructField("store_and_fwd_flag", StringType(), True)
# ])

# df = spark.createDataFrame([], schema)
# df.writeTo("demo.nyc.taxis").create()


# Initialize SparkSession with Hive support
spark = SparkSession.builder \
    .appName("SparkHiveCatalogApp") \
    .config("spark.sql.catalogImplementation", "hive") \
    .config("spark.hadoop.fs.maprfs.impl", "com.mapr.fs.MapRFileSystem") \
    .enableHiveSupport() \
    .getOrCreate()
# spark.sql.catalog.default.type="hive"
# spark.sql.catalog.default.warehouse=<path_to_your_warehouse>
# spark.sql.catalog.default="org.apache.iceberg.spark.SparkSessionCatalog"
# spark.sql.legacy.pathOptionBehavior.enabled=True

# Read data from a Hive table
hive_table = "default.users"
df = spark.sql(f"SELECT * FROM {hive_table}")

# Perform some transformations
filtered_df = df.filter(df['column_name'] > 100)

# Write the processed data to another Hive table
output_table = "default.tempout"
filtered_df.write.mode("overwrite").saveAsTable(output_table)

print("Data successfully written to Hive table:", output_table)

# Stop the SparkSession
spark.stop()