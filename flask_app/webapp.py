from flask import Flask, render_template
from ec2_metadata import ec2_metadata
import boto3
import random

# Define environmental variable FLASK_APP=webapp.py
app = Flask(__name__)

def get_recomm(user_id):
    """Use dynamodb client, don't use resource to define a dynamodb object"""

    dynamodb = boto3.client('dynamodb', region_name="ap-east-1")
    key = {
        "UserID": {"N": user_id}
    }
    response = dynamodb.get_item(TableName="recomm_service", Key=key)
    return response['Item']['CustomerName']['S'], response['Item']['RecommTV']['S']


@app.route('/')
def index():

    user_id = str(random.randint(1,3))
    customername = get_recomm(user_id)[0]
    tv_series = get_recomm(user_id)[1]

    account_id = ec2_metadata.account_id
    ami_id = ec2_metadata.ami_id
    az = ec2_metadata.availability_zone
    instance_id = ec2_metadata.instance_id
    instance_type = ec2_metadata.instance_type
    private_hostname = ec2_metadata.private_hostname
    private_ip = ec2_metadata.private_ipv4
    return render_template("web.html", account_id=account_id, ami_id=ami_id, az=az, \
        instance_id=instance_id, instance_type=instance_type, private_hostname=private_hostname, \
            private_ip=private_ip, customername=customername, tv_series=tv_series)


if __name__ == "__main__":
    app.run()