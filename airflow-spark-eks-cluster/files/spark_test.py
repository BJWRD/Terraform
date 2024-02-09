from pyspark.sql import SparkSession 
import socket

# IP lookup of the Spark Driver so that the Workers/Executors know what IP to connect back to when they start
def get_ip():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.settimeout(0)
    try:
        # Doesn't have to be reachable
        s.connect(('10.254.254.254', 1))
        IP = s.getsockname()[0]
    except Exception:
        IP = '127.0.0.1'
    finally:
        s.close()
    return IP

# Initialize Spark session
spark = SparkSession.builder.appName("S3Spark")\
    .config("spark.hadoop.fs.s3a.impl", "org.apache.hadoop.fs.s3a.S3AFileSystem") \
    .config("spark.driver.host",get_ip()) \
    .getOrCreate()

# S3 configuration
s3_bucket = "airflow-spark-eks-bucket"
s3_key = "test/s3_spark"

# DataFrame
data = [
    ("Emma", "Wright", "Actor", "London", "England"),
    ("Liam", "Carter", "Accountant", "London", "England"),
    ("Jessica", "Evans", "Economist", "Swansea", "Wales"),
    ("Rachael", "Cooper", "Hairdresser", "Glasgow", "Scotland"),
    ("Tom", "Turner", "Hotel Manager", "Glasgow", "Scotland"),
    ("Rick", "Jones", "Historian", "Aberdeen", "Scotland"),
    ("Ross", "Smith", "Civil Engineer", "Cardiff", "Wales"),
    ("Joe", "Dunn", "Chemist", "London", "England"),
    ("Michelle", "Chaplin", "Artist", "Sheffield", "England"),
    ("Chloe", "Quinn", "Chef", "London", "England")
]

columns = ["first_name", "last_name", "profession", "city", "country"]

df = spark.createDataFrame(data, columns)

# Write DataFrame to S3 in CSV format
df.write.mode("overwrite").csv(f"s3a://{s3_bucket}/{s3_key}")

# Read the contents of the created file from S3
s3_file_contents = spark.read.csv(f"s3a://{s3_bucket}/{s3_key}", header=True).collect()

# Print the contents to the logs
for row in s3_file_contents:
    print(row)

# Stop the Spark session
spark.stop()
