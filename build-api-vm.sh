#!/bin/bash
# API VM setup script

echo "🔌 Setting up API VM..."

apt-get update
apt-get install -y apache2 php libapache2-mod-php php-mysql

# Remove default Apache page
rm -f /var/www/html/index.html

# Copy API files from shared www folder
cp /vagrant/www/api.php /var/www/html/
cp /vagrant/www/api-info.html /var/www/html/index.html

# Set proper permissions
chown -R www-data:www-data /var/www/html/
chmod -R 755 /var/www/html/

service apache2 restart

echo "✅ API VM ready at 192.168.56.13"