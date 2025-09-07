cat > build-frontend-vm.sh << 'SCRIPT'
#!/bin/bash
# Frontend VM setup script

echo "🎨 Setting up Frontend VM..."

apt-get update
apt-get install -y apache2

# Remove default page
rm -f /var/www/html/index.html

# Copy frontend files from shared www folder
cp /vagrant/www/index.html /var/www/html/

# Set proper permissions
chown -R www-data:www-data /var/www/html/
chmod -R 755 /var/www/html/

service apache2 restart

echo "✅ Frontend VM ready at 192.168.56.11"
SCRIPT