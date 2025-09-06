# -*- mode: ruby -*-
# vi: set ft=ruby :
# These lines tell text editors this is Ruby code

# Multi-VM Vagrantfile for Task Tracker Assignment
# This creates 2 VMs that can communicate with each other on a private network

Vagrant.configure("2") do |config|
  # The "2" is the Vagrantfile API version (not number of VMs!)
  # This is the base configuration that applies to ALL VMs
  config.vm.box = "bento/ubuntu-22.04"  # Ubuntu 22.04 box that works on Intel and Arm

  # ==========================================
  # WEBSERVER VM DEFINITION
  # ==========================================
  config.vm.define "webserver" do |webserver|
    webserver.vm.hostname = "webserver"
    webserver.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"
    webserver.vm.network "private_network", ip: "192.168.56.11"
    
    webserver.vm.provision "shell", inline: <<-SHELL
      apt-get update
      apt-get install -y apache2 php libapache2-mod-php php-mysql
      
      # Remove default Apache page so PHP gets served
      rm -f /var/www/html/index.html
      
      # Create PHP task tracker (using tee method that worked)
      cat > /var/www/html/index.php << 'PHPEOF'
<!DOCTYPE html>
<html>
<head>
    <title>Task Tracker</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
        .completed { text-decoration: line-through; color: #888; }
        .priority-high { color: #d73027; font-weight: bold; }
        .priority-medium { color: #fc8d59; }
        .priority-low { color: #91bfdb; }
    </style>
</head>
<body>
    <h1>My Task Tracker</h1>
    <p>Database Server: 192.168.56.12</p>
    
    <h2>Current Tasks</h2>
    <table>
        <tr>
            <th>ID</th>
            <th>Title</th>
            <th>Description</th>
            <th>Priority</th>
            <th>Due Date</th>
            <th>Status</th>
        </tr>
        
        <?php
        $db_host = '192.168.56.12';
        $db_name = 'tasktracker';
        $db_user = 'webuser';
        $db_passwd = 'insecure_db_pw';
        
        try {
            $pdo = new PDO("mysql:host=$db_host;dbname=$db_name", $db_user, $db_passwd);
            $query = $pdo->query("SELECT * FROM tasks ORDER BY due_date ASC");
            
            while($task = $query->fetch()) {
                $completed_class = $task['completed'] ? 'completed' : '';
                $priority_class = 'priority-' . $task['priority'];
                $status = $task['completed'] ? 'Completed' : 'Pending';
                
                echo "<tr class='$completed_class'>";
                echo "<td>" . $task['id'] . "</td>";
                echo "<td>" . htmlspecialchars($task['title']) . "</td>";
                echo "<td>" . htmlspecialchars($task['description']) . "</td>";
                echo "<td class='$priority_class'>" . ucfirst($task['priority']) . "</td>";
                echo "<td>" . $task['due_date'] . "</td>";
                echo "<td>" . $status . "</td>";
                echo "</tr>";
            }
        } catch(PDOException $e) {
            echo "<tr><td colspan='6'>Database connection failed: " . $e->getMessage() . "</td></tr>";
        }
        ?>
    </table>
    
    <p><em>VM-to-VM database connection successful!</em></p>
</body>
</html>
PHPEOF
      
      service apache2 restart
      echo "Webserver ready with PHP task tracker"
    SHELL
  end

  # ==========================================
  # DATABASE VM DEFINITION  
  # ==========================================
  config.vm.define "database" do |database|
    database.vm.hostname = "database"
    database.vm.network "private_network", ip: "192.168.56.12"
    
    # Install and configure MySQL database
    database.vm.provision "shell", inline: <<-SHELL
      apt-get update
      
      # Set MySQL root password before installation (prevents interactive prompts)
      export MYSQL_PWD='insecure_mysqlroot_pw'
      echo "mysql-server mysql-server/root_password password $MYSQL_PWD" | debconf-set-selections 
      echo "mysql-server mysql-server/root_password_again password $MYSQL_PWD" | debconf-set-selections
      
      # Install MySQL server
      apt-get install -y mysql-server
      service mysql start
      
      # Create task tracker database
      echo "CREATE DATABASE tasktracker;" | mysql
      
      # Create database user for webserver connections
      echo "CREATE USER 'webuser'@'%' IDENTIFIED BY 'insecure_db_pw';" | mysql
      echo "GRANT ALL PRIVILEGES ON tasktracker.* TO 'webuser'@'%'" | mysql
      
      # Create tasks table
      export MYSQL_PWD='insecure_db_pw'
      cat <<EOF | mysql -u webuser tasktracker
CREATE TABLE tasks (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    completed BOOLEAN DEFAULT FALSE,
    due_date DATE,
    priority ENUM('low', 'medium', 'high') DEFAULT 'medium',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample tasks
INSERT INTO tasks (title, description, completed, due_date, priority) VALUES 
('Learn Vagrant', 'Complete COSC349 multi-VM setup', FALSE, '2025-09-08', 'high'),
('Build Task Tracker', 'Implement web-based task management', FALSE, '2025-09-10', 'high'),
('Test VM Communication', 'Verify database connectivity works', FALSE, '2025-09-07', 'medium');
EOF
      
      # Allow external connections (from webserver VM)
      sed -i'' -e '/bind-address/s/127.0.0.1/0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
      service mysql restart
      
      echo "Database VM ready with tasktracker database"
    SHELL
  end
  
end

# SUMMARY OF WHAT THIS CREATES:
# 1. Two Ubuntu VMs that can talk to each other
# 2. Webserver VM (192.168.56.11) running Apache web server
# 3. Database VM (192.168.56.12) ready for database installation
# 4. Port forwarding so you can access webserver from your browser
# 5. Automatic setup (provisioning) so VMs are ready to use

# NETWORK DIAGRAM:
# Your Computer (Windows)
#     |
#     | Port forwarding 127.0.0.1:8080 → VM port 80
#     |
# Webserver VM (192.168.56.11) ←→ Database VM (192.168.56.12)
#     [Apache web server]           [Ready for MySQL]
#          |
#          | Private network 192.168.56.x
#          |