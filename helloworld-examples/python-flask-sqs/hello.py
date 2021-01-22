#!/usr/bin/env python3

from cfenv import AppEnv
from flask import Flask
import boto3
import os

# setting logging to stdout
from logging.config import dictConfig
dictConfig({
    'version': 1,
    'formatters': {'default': {
        'format': '[%(asctime)s] %(levelname)s in %(module)s: %(message)s',
    }},
    'handlers': {'wsgi': {
        'class': 'logging.StreamHandler',
        'stream': 'ext://sys.stdout',
        'formatter': 'default'
    }},
    'root': {
        'level': 'INFO',
        'handlers': ['wsgi']
    }
})

assert 'VCAP_SERVICES' in os.environ, "no VCAP_SERVICES environment variable set"
app = Flask(__name__)

env = AppEnv()
vcap = env.get_service(label='aws-sqs-queue')
AWS_REGION = vcap.credentials['aws_region']
AWS_ACCESS_KEY_ID = vcap.credentials['aws_access_key_id']
AWS_SECRET_ACCESS_KEY = vcap.credentials['aws_secret_access_key']
AWS_PRIMARY_QUEUE = vcap.credentials['primary_queue_url']
AWS_SECONDARY_QUEUE = vcap.credentials['secondary_queue_url']

sqs = boto3.client('sqs', region_name=AWS_REGION, aws_access_key_id=AWS_ACCESS_KEY_ID, aws_secret_access_key=AWS_SECRET_ACCESS_KEY)


@app.route("/")
def index():
    app.logger.info("Index")
    return """<ul>
                <li><a href='/hello'>/hello</a></li>
                <li><a href='/env'>/env</a></li>
                <li><a href='/send'>/send</a></li>
                <li><a href='/receive'>/receive</a></li>
              </ul>"""


@app.route("/hello")
def hello():
    app.logger.info("Hello SQS")
    return "Hello"


@app.route("/receive")
def receive():
    app.logger.info("receive message from sqs")
    response = sqs.receive_message(
        QueueUrl=AWS_PRIMARY_QUEUE,
        AttributeNames=['SentTimestamp'],
        MaxNumberOfMessages=1,
        MessageAttributeNames=['All'],
        VisibilityTimeout=0,
        WaitTimeSeconds=0)
    message = response['Messages'][0]
    receipt_handle = message['ReceiptHandle']
    sqs.delete_message(
        QueueUrl=AWS_PRIMARY_QUEUE,
        ReceiptHandle=receipt_handle)
    return message


@app.route("/send")
def send():
    app.logger.info("send message to sqs")
    response = sqs.send_message(
        QueueUrl=AWS_PRIMARY_QUEUE,
        MessageBody='Hello SQS this is a test from hello-python-flask-sqs',
        DelaySeconds=10)
    return response


@app.route("/env")
def enviro():
    app.logger.info("check environment")
    return f"region: {AWS_REGION}"


if __name__ == "__main__":
    port = int(os.getenv("PORT", 8080))
    app.run(host="0.0.0.0", port=port, debug=True)
