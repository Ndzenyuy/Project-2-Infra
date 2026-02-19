import boto3
import pymysql
import cryptography
import os

ssm = boto3.client('ssm')

def get_parameter(name, decrypt=False):
    response = ssm.get_parameter(
        Name=name,
        WithDecryption=decrypt
    )
    return response['Parameter']['Value']

def lambda_handler(event, context):

    db_host = os.environ['DB_HOST']
    db_name = os.environ['DB_NAME']
    db_port = int(os.environ['DB_PORT'])  # convert string to int
    username = os.environ['USERNAME']
    password = os.environ['PASSWORD']

    db_host = db_host.split(':')[0]   # Remove port if included in the host

    connection = pymysql.connect(
        host=db_host,
        user=username,
        port=db_port,
        password=password,
        database=db_name
    )

    with connection.cursor() as cursor:
        with open('db_backup.sql', 'r') as f:
            sql_script = f.read()

        for statement in sql_script.split(';'):
            if statement.strip():
                cursor.execute(statement)

    connection.commit()
    connection.close()

    return {"status": "Database configured successfully"}
