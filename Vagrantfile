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
    # This creates a VM named "webserver" 
    # The |webserver| variable lets us configure this specific VM
    
    # Set the hostname inside the VM (what you see in the shell prompt)
    webserver.vm.hostname = "webserver"
    
    # PORT FORWARDING: Connect host port 8080 to VM port 80
    # guest: 80        = port 80 inside the VM (where Apache serves)
    # host: 8080       = port 8080 on your Windows computer  
    # host_ip: "127.0.0.1" = only allow connections from localhost (security)
    # This is WHY http://127.0.0.1:8080 works in your browser!
    webserver.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"
    
    # PRIVATE NETWORK: Give this VM a static IP for VM-to-VM communication
    # This creates a virtual network that only your VMs can use
    # Think of it like a private LAN between your VMs
    webserver.vm.network "private_network", ip: "192.168.56.11"
    
    # PROVISIONING: Commands that run ONCE when VM is first created
    # This is like a script that sets up the VM automatically
    webserver.vm.provision "shell", inline: <<-SHELL
      # Update Ubuntu package lists (like running Windows Update)
      apt-get update
      
      # Install Apache web server
      apt-get install -y apache2
      
      # Create a custom web page (overwrites Apache default page)
      # The > creates/overwrites the file, >> appends to it
      echo "<h1>Task Tracker Webserver</h1>" > /var/www/html/index.html
      echo "<p>Webserver VM IP: 192.168.56.11</p>" >> /var/www/html/index.html
      
      # Apache automatically serves files from /var/www/html/
      # So index.html becomes the homepage you see in your browser
    SHELL
  end

  # ==========================================
  # DATABASE VM DEFINITION  
  # ==========================================
  config.vm.define "database" do |database|
    # This creates a second VM named "database"
    
    database.vm.hostname = "database"
    
    # Give database VM a different IP on the same private network
    # Now webserver (192.168.56.11) can talk to database (192.168.56.12)
    database.vm.network "private_network", ip: "192.168.56.12"
    
    # Minimal provisioning for now - just update packages
    database.vm.provision "shell", inline: <<-SHELL
      apt-get update
      # This echo command just confirms the VM was provisioned
      echo "Database VM provisioned at 192.168.56.12"
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