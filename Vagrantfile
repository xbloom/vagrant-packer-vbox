# -*- mode: ruby -*-
# vi: set ft=ruby :

# Fail if Vagrant version is too old
begin
  Vagrant.require_version ">= 1.9.0"
rescue NoMethodError
  $stderr.puts "This Vagrantfile requires Vagrant version >= 1.9.0"
  exit 1
end

Vagrant.configure("2") do |config|
  
  config.vm.box = "rocky-8.4-x86_64-vbox"
  config.vm.box_check_update = false

  config.vm.synced_folder "./", "/vagrant", create: true, group: "vagrant", owner: "vagrant"
  
  if Vagrant.has_plugin?("vagrant-vbguest")
    config.vbguest.auto_update = false
    config.vbguest.no_remote = true
  end

  # Override locale settings. Avoids host locale settings being sent via SSH
  ENV['LC_ALL']="en_US.UTF-8"
  ENV['LANG']="en_US.UTF-8"
  ENV['LANGUAGE']="en_US.UTF-8"
  
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"
  # config.vm.network "private_network", ip: "192.168.33.10"
  # RFC 5737 TEST-NET-1 used to avoid DNS rebind protection
  config.vm.network "private_network", ip: "192.0.2.100"
  # config.vm.network "public_network"
  
  config.vm.provider "virtualbox" do |v, override|

    v.memory = ENV["VAGRANT_MEMORY"] || 2048
    v.cpus = ENV["VAGRANT_CPUS"] || 2
  end
  
  config.vm.provision "shell", inline: <<-SHELL
    
  SHELL

  if File.exists?("script/custom-vagrant")
    config.vm.provision "shell", path: "script/custom-vagrant"
  end
end
