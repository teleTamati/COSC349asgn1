# -*- mode: ruby -*-
# vi: set ft=ruby :

# 3-VM Task Tracker - Lab 6 Style Organization
Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-22.04"

  # Database VM
  config.vm.define "database" do |database|
    database.vm.hostname = "database"
    database.vm.network "private_network", ip: "192.168.56.12"
    database.vm.provision "shell", path: "build-database-vm.sh"
  end

  # API VM  
  config.vm.define "api" do |api|
    api.vm.hostname = "api"
    api.vm.network "private_network", ip: "192.168.56.13"
    api.vm.network "forwarded_port", guest: 80, host: 8081, host_ip: "127.0.0.1"
    api.vm.provision "shell", path: "build-api-vm.sh"
  end

  # Frontend VM
  config.vm.define "frontend" do |frontend|
    frontend.vm.hostname = "frontend"  
    frontend.vm.network "private_network", ip: "192.168.56.11"
    frontend.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"
    frontend.vm.provision "shell", path: "build-frontend-vm.sh"
  end
end