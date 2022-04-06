#!/usr/bin/bash 

yum -y update
sleep 10
yum install python3
pip3 install flask
pip3 install boto3
pip3 install ec2_metadata
mkdir templates
wget https://my-server-code-8371.s3.ap-east-1.amazonaws.com/webapp.py
cd templates
wget https://my-server-code-8371.s3.ap-east-1.amazonaws.com/templates/web.html
cd ..
export FLASK_APP=webapp.py
flask run -h 0.0.0.0 -p 5000