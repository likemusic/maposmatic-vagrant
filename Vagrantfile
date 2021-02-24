# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.network "forwarded_port", guest: 80, host: 8000

  config.vm.synced_folder ".", "/vagrant/", mount_options: ["dmode=777"]
  config.vm.synced_folder "test", "/vagrant/test", mount_options: ["dmode=777"]

  config.vm.boot_timeout = 600
  config.ssh.forward_agent = true
  config.ssh.forward_x11 = true

  config.vm.provider "virtualbox" do |vb|
    vb.vm.box = "generic/ubuntu2004"
    # vb.gui = true
    vb.name = "maposmatic"
    vb.memory = "3072"
    vb.cpus   = "2"
  end

  config.vm.provider "docker" do |d|
    d.image = "ubuntu:18.04"
  end

    if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :box
    config.cache.synced_folder_opts = {
      owner: "_apt"
    }
  end

  unless Vagrant.has_plugin?("vagrant-vbguest")
    raise 'vbguest plugin is not installed - run "vagrant plugin install vagrant-vbguest" first'
  end

  unless Vagrant.has_plugin?("vagrant-disksize")
    raise 'disksize plugin is not installed - run "vagrant plugin install vagrant-disksize" first'
  end
  config.disksize.size = '150GB'

  config.ssh.forward_x11=true

  config.vm.provision "shell",
    env: {
      "GIT_AUTHOR_NAME":  "#{ENV['GIT_AUTHOR_NAME']}",
      "GIT_AUTHOR_EMAIL": "#{ENV['GIT_AUTHOR_EMAIL']}"
    },
    path: "provision.sh"

end
