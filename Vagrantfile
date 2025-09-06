# -*- mode: ruby -*-
# vi: set ft=ruby :

# 3-VM Task Tracker: Frontend + API + Database
Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-22.04"

  # ==========================================
  # DATABASE VM (Start first - others depend on it)
  # ==========================================
  config.vm.define "database" do |database|
    database.vm.hostname = "database"
    database.vm.network "private_network", ip: "192.168.56.12"
    
    database.vm.provision "shell", inline: <<-SHELL
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
      
      # Create tasks table with sample data
      export MYSQL_PWD='insecure_api_pw'
      cat <<EOF | mysql -u apiuser tasktracker
CREATE TABLE tasks (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    completed BOOLEAN DEFAULT FALSE,
    due_date DATE,
    priority ENUM('low', 'medium', 'high') DEFAULT 'medium',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO tasks (title, description, completed, due_date, priority) VALUES 
('Setup 3-VM Architecture', 'Split into Frontend + API + Database VMs', FALSE, '2025-09-08', 'high'),
('Build REST API', 'Create PHP endpoints for task management', FALSE, '2025-09-09', 'high'),
('Create Frontend Interface', 'Build JavaScript interface for task tracker', FALSE, '2025-09-10', 'medium'),
('Test VM Communication', 'Verify all 3 VMs work together', FALSE, '2025-09-11', 'medium');
EOF
      
      # Allow external connections from API VM
      sed -i'' -e '/bind-address/s/127.0.0.1/0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
      service mysql restart
      
      echo "Database VM ready at 192.168.56.12"
    SHELL
  end

  # ==========================================
  # API VM (PHP backend that talks to database)
  # ==========================================
  config.vm.define "api" do |api|
    api.vm.hostname = "api"
    api.vm.network "private_network", ip: "192.168.56.13"
    api.vm.network "forwarded_port", guest: 80, host: 8081, host_ip: "127.0.0.1"
    
    api.vm.provision "shell", inline: <<-SHELL
      apt-get update
      apt-get install -y apache2 php libapache2-mod-php php-mysql
      
      # Remove default Apache page
      rm -f /var/www/html/index.html
      
      # Create REST API endpoint
      cat > /var/www/html/api.php << 'APIEOF'
<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE');
header('Access-Control-Allow-Headers: Content-Type');

$db_host = '192.168.56.12';
$db_name = 'tasktracker';
$db_user = 'apiuser';
$db_passwd = 'insecure_api_pw';

try {
    $pdo = new PDO("mysql:host=$db_host;dbname=$db_name", $db_user, $db_passwd);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    $method = $_SERVER['REQUEST_METHOD'];
    
    if ($method === 'GET') {
        // Get all tasks
        $query = $pdo->query("SELECT * FROM tasks ORDER BY due_date ASC");
        $tasks = $query->fetchAll(PDO::FETCH_ASSOC);
        echo json_encode(['success' => true, 'tasks' => $tasks]);
        
    } else {
        echo json_encode(['success' => false, 'message' => 'Method not implemented yet']);
    }
    
} catch(PDOException $e) {
    echo json_encode(['success' => false, 'message' => 'Database error: ' . $e->getMessage()]);
}
?>
APIEOF

      # Create API info page
      cat > /var/www/html/index.html << 'INFOEOF'
<!DOCTYPE html>
<html>
<head><title>Task Tracker API</title></head>
<body>
    <h1>Task Tracker API Server</h1>
    <p>API VM running at 192.168.56.13</p>
    <p>Database VM at 192.168.56.12</p>
    <h3>API Endpoints:</h3>
    <ul>
        <li><a href="/api.php">GET /api.php</a> - Get all tasks</li>
    </ul>
</body>
</html>
INFOEOF
      
      service apache2 restart
      echo "API VM ready at 192.168.56.13"
    SHELL
  end

  # ==========================================
  # FRONTEND VM (JavaScript interface)
  # ==========================================
  config.vm.define "frontend" do |frontend|
    frontend.vm.hostname = "frontend"  
    frontend.vm.network "private_network", ip: "192.168.56.11"
    frontend.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"
    
    frontend.vm.provision "shell", inline: <<-SHELL
      apt-get update
      apt-get install -y apache2
      
      # Remove default page
      rm -f /var/www/html/index.html
      
      # Create modern JavaScript frontend
      cat > /var/www/html/index.html << 'FRONTEOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Task Tracker</title>
    <style>
        body { 
            font-family: 'Segoe UI', Arial, sans-serif; 
            margin: 0; 
            padding: 20px;
            background-color: #f5f5f5;
        }
        .container { 
            max-width: 1000px; 
            margin: 0 auto; 
            background: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        h1 { color: #333; text-align: center; }
        .status { 
            padding: 10px; 
            margin: 10px 0; 
            border-radius: 4px;
            text-align: center;
        }
        .loading { background-color: #e3f2fd; color: #1976d2; }
        .error { background-color: #ffebee; color: #c62828; }
        .success { background-color: #e8f5e8; color: #2e7d32; }
        
        table { 
            width: 100%; 
            border-collapse: collapse; 
            margin-top: 20px;
        }
        th, td { 
            padding: 12px; 
            text-align: left; 
            border-bottom: 1px solid #ddd; 
        }
        th { 
            background-color: #f8f9fa; 
            font-weight: 600;
            color: #555;
        }
        tr:hover { background-color: #f5f5f5; }
        
        .priority-high { color: #d32f2f; font-weight: bold; }
        .priority-medium { color: #f57c00; }
        .priority-low { color: #388e3c; }
        
        .completed { 
            text-decoration: line-through; 
            opacity: 0.6; 
        }
        
        .architecture {
            margin-top: 30px;
            padding: 20px;
            background-color: #f8f9fa;
            border-radius: 4px;
            font-size: 14px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🗂️ Task Tracker</h1>
        <div id="status" class="status loading">Loading tasks from API...</div>
        
        <table id="tasksTable" style="display: none;">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Title</th>
                    <th>Description</th>
                    <th>Priority</th>
                    <th>Due Date</th>
                    <th>Status</th>
                </tr>
            </thead>
            <tbody id="tasksBody">
            </tbody>
        </table>
        
        <div class="architecture">
            <h3>3-VM Architecture:</h3>
            <p><strong>Frontend VM (192.168.56.11):</strong> This page - JavaScript interface</p>
            <p><strong>API VM (192.168.56.13):</strong> PHP REST API endpoint</p>
            <p><strong>Database VM (192.168.56.12):</strong> MySQL database</p>
            <p><em>Frontend → API → Database communication chain</em></p>
        </div>
    </div>

    <script>
        // Load tasks from API VM
        async function loadTasks() {
            try {
                const response = await fetch('http://127.0.0.1:8081/api.php');
                const data = await response.json();
                
                const statusDiv = document.getElementById('status');
                const table = document.getElementById('tasksTable');
                const tbody = document.getElementById('tasksBody');
                
                if (data.success) {
                    statusDiv.className = 'status success';
                    statusDiv.textContent = `✅ Loaded ${data.tasks.length} tasks from 3-VM architecture`;
                    
                    tbody.innerHTML = '';
                    data.tasks.forEach(task => {
                        const row = tbody.insertRow();
                        const completedClass = task.completed === '1' ? 'completed' : '';
                        const priorityClass = `priority-${task.priority}`;
                        const status = task.completed === '1' ? 'Completed' : 'Pending';
                        
                        row.className = completedClass;
                        row.innerHTML = `
                            <td>${task.id}</td>
                            <td>${escapeHtml(task.title)}</td>
                            <td>${escapeHtml(task.description)}</td>
                            <td class="${priorityClass}">${capitalizeFirst(task.priority)}</td>
                            <td>${task.due_date}</td>
                            <td>${status}</td>
                        `;
                    });
                    
                    table.style.display = 'table';
                } else {
                    statusDiv.className = 'status error';
                    statusDiv.textContent = `❌ API Error: ${data.message}`;
                }
            } catch (error) {
                const statusDiv = document.getElementById('status');
                statusDiv.className = 'status error';
                statusDiv.textContent = `❌ Connection Error: ${error.message}`;
            }
        }
        
        function escapeHtml(text) {
            const div = document.createElement('div');
            div.textContent = text;
            return div.innerHTML;
        }
        
        function capitalizeFirst(str) {
            return str.charAt(0).toUpperCase() + str.slice(1);
        }
        
        // Load tasks when page loads
        document.addEventListener('DOMContentLoaded', loadTasks);
    </script>
</body>
</html>
FRONTEOF
      
      service apache2 restart
      echo "Frontend VM ready at 192.168.56.11"
    SHELL
  end
end