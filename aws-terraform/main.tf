provider "aws" {
  region = "us-east-1"
}

# Security Groups (same pattern as your Lab 9)
resource "aws_security_group" "allow_ssh" {
  name        = "tasktracker-allow-ssh"
  description = "Allow inbound SSH traffic"

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_web" {
  name = "tasktracker-allow-web"
  description = "Allow inbound HTTP and HTTPS traffic"

  ingress {
    description = "HTTP from anywhere"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from anywhere"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_mysql" {
  name = "tasktracker-allow-mysql"
  description = "Allow MySQL database interactions (Port 3306)"

  ingress {
    description = "MySQL from API servers only"
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    security_groups = [aws_security_group.api_servers.id]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "api_servers" {
  name        = "tasktracker-api-servers"
  description = "API servers security group"

  ingress {
    description = "HTTP from anywhere (for testing)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # We'll restrict this later
  }

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# RDS Database (replaces your VM database from Lab 9)
resource "aws_db_instance" "tasktracker_db" {
  identifier     = "tasktracker-db"
  engine         = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"
  
  allocated_storage = 20
  storage_type     = "gp2"
  
  db_name  = "tasktracker"
  username = "webuser"
  password = "insecure_db_pw"
  
  vpc_security_group_ids = [aws_security_group.allow_mysql.id]
  
  skip_final_snapshot = true
  deletion_protection = false

  tags = {
    Name = "TaskTracker-Database"
  }
}

# Frontend EC2 Instance (same pattern as your web_server from Lab 9)
resource "aws_instance" "frontend_server" {
  ami           = "ami-0360c520857e3138f"  # Same Ubuntu AMI as your Lab 9
  instance_type = "t2.micro"
  key_name      = "cosc349@2025"  # Your key name from Lab 9

  vpc_security_group_ids = [
    aws_security_group.allow_web.id,
    aws_security_group.allow_ssh.id
  ]

  user_data = templatefile("${path.module}/build-frontend-vm.tpl", {
    s3_bucket_name = "tasktracker-YOUR_STUDENT_ID-assets",  # We'll update this
    api_server_ip  = aws_instance.api_server.private_ip
  })

  tags = {
    Name = "TaskTracker-Frontend"
  }
}

# API EC2 Instance (similar to your mysql_server from Lab 9)
resource "aws_instance" "api_server" {
  ami           = "ami-0360c520857e3138f"
  instance_type = "t2.micro"
  key_name      = "cosc349@2025"

  vpc_security_group_ids = [
    aws_security_group.api_servers.id,
    aws_security_group.allow_ssh.id
  ]

  user_data = templatefile("${path.module}/build-api-vm.tpl", {
    s3_bucket_name = "tasktracker-YOUR_STUDENT_ID-assets",  # We'll update this
    db_host        = aws_db_instance.tasktracker_db.endpoint,
    db_name        = aws_db_instance.tasktracker_db.db_name,
    db_user        = aws_db_instance.tasktracker_db.username,
    db_password    = aws_db_instance.tasktracker_db.password
  })

  tags = {
    Name = "TaskTracker-API"
  }
}

# Outputs (same pattern as your Lab 9)
output "frontend_server_ip" {
  value = aws_instance.frontend_server.public_ip
}

output "api_server_ip" {
  value = aws_instance.api_server.public_ip
}

output "database_endpoint" {
  value = aws_db_instance.tasktracker_db.endpoint
}

output "frontend_url" {
  value = "http://${aws_instance.frontend_server.public_ip}"
}

output "api_url" {
  value = "http://${aws_instance.api_server.public_ip}"
}