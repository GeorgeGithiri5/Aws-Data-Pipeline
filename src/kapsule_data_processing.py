"""This job take raw data from kapsule database."""

import sys
import boto3
import json
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
import mysql.connector
import pandas as pd
from pyspark.sql.functions import hash
from awsglue.dynamicframe import DynamicFrame

## @params: [JOB_NAME]
args = getResolvedOptions(sys.argv, ['JOB_NAME'])

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)
job.commit()

path = f"s3://kapsule-bucket/data/admin"
mysql_url = "jdbc:mysql://dball.cforczwywawk.eu-west-2.rds.amazonaws.com:3306/openclinic_dbo"
mysql_url_admin = "jdbc:mysql://dball.cforczwywawk.eu-west-2.rds.amazonaws.com:3306/ocadmin_dbo"

def get_redshift_secret():
    secret_name = "arn:aws:secretsmanager:us-east-1:881401823878:secret:sqlworkbench!f449be75-44f3-4cb6-8f34-7d90bab3f0f8-txUjHk"
    region_name = "us-east-1"

    # Create a Secrets Manager client
    session = boto3.session.Session()
    client = session.client(service_name="secretsmanager", region_name=region_name)

    get_secret_value_response = client.get_secret_value(SecretId=secret_name)
    secret = json.loads(get_secret_value_response["SecretString"])
    return secret

def get_kapsule_database_secret():
    secret_name = "arn:aws:secretsmanager:us-east-1:881401823878:secret:kapsule_creds-0JURRk"
    region_name = "us-east-1"

    # Create a Secrets Manager client
    session = boto3.session.Session()
    client = session.client(service_name="secretsmanager", region_name=region_name)

    get_secret_value_response = client.get_secret_value(SecretId=secret_name)
    secret = json.loads(get_secret_value_response["SecretString"])
    return secret

def load_data_to_redshift(table, s_dframe):
    dyn_df = DynamicFrame.fromDF(s_dframe, glueContext, "dyn_df")
    redshift_secret = get_redshift_secret()
    url_link = redshift_secret["redshift_host"],
    redshift_port = redshift_secret["redshift_port"],
    redshift_username = redshift_secret["redshift_username"],
    redshift_password = redshift_secret["redshift_password"],
    
    redshift_conn_options = {
        "url": url_link,
        "dbtable": f"kapsule.{table}",
        "user": redshift_username,
        "password": redshift_password,
        "redshiftTmpDir": args["TempDir"],
    }

    aws_redshift = glueContext.write_dynamic_frame.from_options(
        frame=dyn_df,
        connection_type="redshift",
        connection_options=redshift_conn_options,
    )

# This function is reusable to do all connections to mysql in this job
def connection_to_mysql(mysql_endpoint, table):
    kapsule_database_creds = get_kapsule_database_secret()
    username_kapsule = kapsule_database_creds['username_kapsule']
    password_kapsule = kapsule_database_creds['password_kapsule']
    
    conn = spark.read.format("jdbc").option("url", mysql_endpoint) \
        .option("driver", "com.mysql.jdbc.Driver").option("dbtable", table) \
        .option("user", username_kapsule).option("password", password_kapsule).load()
        
    return conn


def read_data(mysql_endpoint, table):
    sdf = connection_to_mysql(mysql_endpoint, table)
    return sdf
        
def write_data_to_s3():
    tables = ['oc_encounters', 'oc_encounters_history', 'oc_prescriptions', 'oc_prestations','oc_prestations_history', 'oc_problems', 'oc_problems_history','oc_rfe', 'icd10', 'icpc2']
    for table in tables:
        dataframe = read_data(mysql_url, table)
        path = f"s3://kapsule-bucket/data/{table}"
        dataframe.write.format("csv") \
        .option("sep", ",")  \
        .option('header','true') \
        .mode("overwrite").save(path)
        load_data_to_redshift(table, dataframe)

def write_data_to_s3_admin():
    # adminprivate
    dataframe = read_data(mysql_url_admin, 'adminprivate') \
    .withColumn('mobile', hash('mobile')) \
    .withColumn('telephone', hash('telephone')) # Hashing mobile and telephone of a patient
    
    path = f"s3://kapsule-bucket/data/adminprivate"
    dataframe.write.format("csv") \
    .option("sep", ",") \
    .option('header','true') \
    .mode("overwrite").save(path)
    
    # Write data to redshift
    load_data_to_redshift("adminprivate", dataframe)
    
    # Admin Table To S3
    dataframe = read_data(mysql_url_admin, 'admin') \
    .withColumn('lastname', hash('lastname')) \
    .withColumn('firstname', hash('firstname')) # Hashing lastname and firstname of a patient
    
    dataframe.write.format("csv").option("sep", ",").option('header','true').mode("overwrite").save(path)
    load_data_to_redshift('admin', dataframe)

def main():
    write_data_to_s3()
    write_data_to_s3_admin()
    
if __name__ == "__main__":
    main()
    job.commit()
    