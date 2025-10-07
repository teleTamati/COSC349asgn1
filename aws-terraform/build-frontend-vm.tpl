#!/bin/bash

echo "API_SERVER_IP=${api_server_ip}" >> /etc/environment
echo "S3_BUCKET=${s3_bucket_name}" >> /etc/environment

echo "Setup of frontend VM has begun." > /var/log/user.log

# Update and install packages (same as your Lab 9)
apt-get update
apt-get install -y apache2 awscli

# Remove default page
rm -f /var/www/html/index.html

# Download frontend files from S3
aws s3 cp s3://${s3_bucket_name}/www/index.html /var/www/html/index.html

# Update the frontend to point to API server private IP
sed -i "s/192\.168\.56\.11/${api_server_ip}/g" /var/www/html/index.html

# Set proper permissions
chown www-data:www-data /var/www/html/index.html
chmod 644 /var/www/html/index.html

# Restart Apache (same as your Lab 9)
service apache2 restart

echo "Setup of frontend VM has completed." > /var/log/user.log