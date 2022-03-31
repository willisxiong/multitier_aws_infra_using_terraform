#!/usr/bin/bash 

yum -y update
sleep 10
yum -y install httpd
systemctl enable httpd
systemctl start httpd
echo '<h1><center>Success</center></h1>' > healthcheck.html
hostname >> healthcheck.html
mv healthcheck.html /var/www/html/
