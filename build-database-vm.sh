cat > build-database-vm.sh << 'SCRIPT'
#!/bin/bash
# Database VM setup script

echo "🗄️ Setting up Database VM..."

apt-get update

# Set MySQL root password before installation
export MYSQL_PWD='insecure_mysqlroot_pw'
echo "mysql-server mysql-server/root_password password $MYSQL_PWD" | debconf-set-selections 
echo "mysql-server mysql-server/root_password_again password $MYSQL_PWD" | debconf-set-selections

# Install MySQL server
apt-get install -y mysql-server
service mysql start

# Create task tracker database and user
echo "CREATE DATABASE tasktracker;" | mysql
echo "CREATE USER 'apiuser'@'%' IDENTIFIED BY 'insecure_api_pw';" | mysql
echo "GRANT ALL PRIVILEGES ON tasktracker.* TO 'apiuser'@'%';" | mysql

# Import schema and sample data
export MYSQL_PWD='insecure_api_pw'
mysql -u apiuser tasktracker < /vagrant/setup-database.sql

# Allow external connections from API VM
sed -i'' -e '/bind-address/s/127.0.0.1/0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
service mysql restart

echo "✅ Database VM ready at 192.168.56.12"
SCRIPT