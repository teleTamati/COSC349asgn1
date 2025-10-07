#!/bin/bash

echo "DB_HOST=${db_host}" >> /etc/environment
echo "DB_NAME=${db_name}" >> /etc/environment
echo "DB_USER=${db_user}" >> /etc/environment
echo "S3_BUCKET=${s3_bucket_name}" >> /etc/environment

echo "Setup of API server has begun." > /var/log/user.log

# Update and install packages (same pattern as your Lab 9)
apt-get update
apt-get install -y apache2 php libapache2-mod-php php-mysql awscli mysql-client

# Remove default page
rm -f /var/www/html/index.html

# Download API files from S3
aws s3 cp s3://${s3_bucket_name}/www/api.php /var/www/html/api.php
aws s3 cp s3://${s3_bucket_name}/www/api-info.html /var/www/html/index.html

# Update database connection in api.php
sed -i "s/\$db_host = '192\.168\.56\.12';/\$db_host = '${db_host}';/" /var/www/html/api.php
sed -i "s/\$db_passwd = 'insecure_api_pw';/\$db_passwd = '${db_password}';/" /var/www/html/api.php
sed -i "s/\$db_user = 'apiuser';/\$db_user = '${db_user}';/" /var/www/html/api.php
sed -i "s/\$db_name = 'tasktracker';/\$db_name = '${db_name}';/" /var/www/html/api.php

# Set proper permissions
chown www-data:www-data /var/www/html/*
chmod 644 /var/www/html/*

# Restart Apache
service apache2 restart

echo "Setup of API server has completed." > /var/log/user.log