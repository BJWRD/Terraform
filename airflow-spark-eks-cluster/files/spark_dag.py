from datetime import datetime, timedelta
from airflow import DAG
from airflow.providers.apache.spark.operators.spark_submit import SparkSubmitOperator
from airflow.models import Variable

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
}

dag = DAG(
    dag_id='spark_test_dag',
    description='A simple Airflow DAG to test out Spark Operator capabilities',
    start_date=datetime(2024, 1, 18),
    schedule_interval='0 * * * *',
    default_args=default_args,
)

spark_conn_id = 'spark'
spark_script_path= '/opt/airflow/dags/repo/spark_test.py'

# Define SparkSubmitOperator task
spark_task = SparkSubmitOperator(
    task_id='spark_task',
    application=spark_script_path,  # Spark script path
    conn_id=spark_conn_id,  # Connection ID for Apache Spark
    name='spark_test_job',
    execution_timeout=timedelta(minutes=15),  # Spark job runtime
    dag=dag,
    packages='org.apache.hadoop:hadoop-aws:3.3.4', # Hadoop-AWS download
    conf={ 
        'spark.hadoop.fs.s3a.access.key': Variable.get("AWS_ACCESS_KEY_ID"),
        'spark.hadoop.fs.s3a.secret.key': Variable.get("AWS_SECRET_ACCESS_KEY"),
    },
)

# Task dependencies
spark_task