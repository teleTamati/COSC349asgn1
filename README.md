# 🗂️ Task Tracker - 3-VM Microservices Architecture

A distributed task management application demonstrating cloud-ready software development using virtualization. Built with a complete separation of concerns across three virtual machines.

---

##  Architecture Overview

This application showcases modern microservices principles using VM-based deployment:

- **Frontend VM (192.168.56.11)** – Static web interface served via Apache  
- **API VM (192.168.56.13)** – PHP REST API handling business logic  
- **Database VM (192.168.56.12)** – MySQL database for data persistence  

All VMs communicate over a private network, demonstrating scalable, cloud-ready architecture patterns.

---

## ✨ Features

-  **Create Tasks** – Add tasks with title, description, and priority levels  
-  **Priority System** – Visual priority indicators (High/Medium/Low)  
-  **Live Updates** – Real-time communication between all three VMs  
-  **Responsive Design** – Clean, modern web interface  

---

## 🚀 Quick Start

### Prerequisites
- Vagrant installed  
- VirtualBox installed  
- At least 4GB available RAM  

### Setup & Deployment
```bash
# Clone the repository
git clone https://github.com/teleTamati/COSC349asgn1.git
cd COSC349asgn1

# Start all VMs (automated provisioning)
vagrant up
