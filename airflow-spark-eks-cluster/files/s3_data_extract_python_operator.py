from datetime import datetime
from airflow import DAG
from airflow.providers.amazon.aws.operators.s3 import S3ListOperator
from airflow.providers.amazon.aws.sensors.s3 import S3KeySensor
from airflow.operators.python_operator import PythonOperator
from airflow.operators.bash_operator import BashOperator
from airflow.hooks.S3_hook import S3Hook
import pandas as pd
from botocore.exceptions import NoCredentialsError

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
}

dag = DAG(
    dag_id='s3_data_extract_python_operator',
    description='A simple Airflow DAG to test out S3 Operator capabilities',
    start_date=datetime(2024, 1, 18),
    schedule_interval='*/5 * * * *',
    default_args=default_args,
)

aws_conn_id = 's3_conn'
s3_bucket = 'airflow-spark-eks-bucket'
prefix = 'test/'
s3_key = 's3://airflow-spark-eks-bucket/test/dummy_data.csv'
dummy_key = 'test/dummy_data.csv'
london_s3_key = 'test/london_dummy_data.csv'

file_content = """
first_name,surname,profession,city,country
Emma,Wright,Actor,London,England
Liam,Carter,Accountant,London,England
Jessica,Evans,Economist,Swansea,Wales
Rachael,Cooper,Hairdresser,Glasgow,Scotland
Tom,Turner,Hotel Manager,Glasgow,Scotland
Rick,Jones,Historian,Aberdeen,Scotland
Ross,Smith,Civil Engineer,Cardiff,Wales
Joe,Dunn,Chemist,London,England
Michelle,Chaplin,Artist,Sheffield,England
Chloe,Quinn,Chef,London,England
"""

def create_s3_object():
    try:
        # Initialize a session using Amazon S3.
        s3_hook = S3Hook(aws_conn_id=aws_conn_id)

        # Check if the key already exists
        key_exists = s3_hook.check_for_key(bucket_name=s3_bucket, key=dummy_key)

        if not key_exists:
            # Create S3 object only if it doesn't already exist
            s3_hook.load_string(file_content, key=dummy_key, bucket_name=s3_bucket)
            print("S3 object created successfully.")
        else:
            print("S3 object already exists. Skipping creation.")

    except NoCredentialsError:
        print("Credentials not available")
    except ValueError as e:
        # Catch the specific exception when the key already exists
        print(f"Caught exception: {e}. Skipping S3 object creation.")

# Create S3 object only if it doesn't already exist
create_s3_object_task = PythonOperator(
    task_id='create_s3_object',
    python_callable=create_s3_object,
    provide_context=True,
    dag=dag,
)

def pass_file_content_to_next_task(**kwargs):
    ti = kwargs['ti']
    # Pushing the content of the file to XCom
    ti.xcom_push(key='file_content', value=file_content)

# Task to pass the file content to the next task
pass_file_content_task = PythonOperator(
    task_id='pass_file_content',
    python_callable=pass_file_content_to_next_task,
    provide_context=True,
    dag=dag,
)

# Task to check if data_dummy.csv file exists in S3 bucket and has been created after the previous tasks
check_s3_key_existence_task = S3KeySensor(
    task_id='check_s3_key_existence',
    bucket_name=s3_bucket,
    bucket_key=dummy_key,
    aws_conn_id=aws_conn_id,
    timeout=600,
    poke_interval=60,
    mode='poke',
    dag=dag,
)

### Task to print the list of files in the S3 bucket prefix /test
s3_file = S3ListOperator(
    task_id="list_s3_files",
    bucket=s3_bucket,
    prefix=prefix,
    aws_conn_id=aws_conn_id,
    dag=dag,
)

def print_list_of_files(**kwargs):
    # Extract the Task Instance object from the keyword arguments
    ti = kwargs['ti']
    # Use Task Instance to pull XCom data from list_s3_files task
    list_of_files = ti.xcom_pull(task_ids='list_s3_files')
    print("List of files:", list_of_files)

print_files_task = PythonOperator(
    task_id='print_list_of_files',
    python_callable=print_list_of_files,
    provide_context=True,
    dag=dag,
)

# Task to install the required library s3fs
install_s3fs_task = BashOperator(
    task_id='install_s3fs',
    bash_command='pip install s3fs',
    dag=dag,
)

# Task to list contents of the CSV file directly from S3
def list_csv_contents_from_s3():
    try:
        # Initialize a session using Amazon S3.
        s3_hook = S3Hook(aws_conn_id=aws_conn_id)

        # Parse the S3 URL to get the bucket name and key
        s3_url_parts = s3_key.replace('s3://', '').split('/')
        bucket_name = s3_url_parts[0]
        s3_key_without_prefix = '/'.join(s3_url_parts[1:])

        # Read the CSV file directly from S3 using pandas
        df = pd.read_csv(s3_hook.get_key(bucket_name=bucket_name, key=s3_key_without_prefix).get()['Body'])

        # Print the contents
        print("CSV Contents:")
        print(df)

    except NoCredentialsError:
        print("Credentials not available")

# PythonOperator to execute the list_csv_contents_from_s3 function
list_csv_contents_task = PythonOperator(
    task_id='list_csv_contents_task',
    python_callable=list_csv_contents_from_s3,
    provide_context=True,
    dag=dag,
)

# Task to filter 'London' data and create a new S3 file
def filter_and_create_london_data(**kwargs):
    ti = kwargs['ti']
    # Pulling the content of the file from XCom
    ti.xcom_push(key='file_content', value=file_content)

    try:
        # Initialize a session using Amazon S3.
        s3_hook = S3Hook(aws_conn_id=aws_conn_id)

        # Parse the S3 URLs to get the bucket name and keys
        s3_key_parts = s3_key.replace('s3://', '').split('/')
        bucket_name = s3_key_parts[0]
        s3_key_without_prefix = '/'.join(s3_key_parts[1:])
        london_data = "\n".join([line for line in file_content.split('\n') if 'London' in line])

        # Check if the target key already exists
        key_exists = s3_hook.check_for_key(bucket_name=bucket_name, key=london_s3_key)

        if not key_exists:
            # Create a new S3 file with 'London' data
            london_data = "\n".join([line for line in file_content.split('\n') if 'London' in line])
            s3_hook.load_string(london_data, key=london_s3_key, bucket_name=bucket_name)
            print("London data copied to london_dummy_data.csv")

    except NoCredentialsError:
        print("Credentials not available")

# Filter and create London data only if it doesn't exist
filter_london_data_task = PythonOperator(
    task_id='filter_london_data_task',
    python_callable=filter_and_create_london_data,
    provide_context=True,
    dag=dag,
)

### Task dependencies
create_s3_object_task >> pass_file_content_task >> check_s3_key_existence_task >> s3_file >> print_files_task >> install_s3fs_task >> list_csv_contents_task >> filter_london_data_task
