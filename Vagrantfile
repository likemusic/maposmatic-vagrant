# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "generic/ubuntu2004"

  config.vm.network "forwarded_port", guest: 80, host: 8000

  config.vm.boot_timeout = 600
  config.ssh.forward_agent = true
  config.ssh.forward_x11 = true

  config.vm.provider "virtualbox" do |vb, override|
    # vb.gui = true
    vb.name = "maposmatic"
    vb.memory = ENV.fetch("VM_MEMORY", 3072)
    vb.cpus   = ENV.fetch("VM_CPUS", 2)

    override.vm.synced_folder ".", "/vagrant/", mount_options: ["dmode=777"]
    override.vm.synced_folder "maposmatic", "/home/maposmatic", mount_options: ["dmode=777"]
  end

  config.vm.provider "hyperv" do |h, override|
    h.memory = ENV.fetch("VM_MEMORY", 3072)
    h.cpus = ENV.fetch("VM_CPUS", 2)

    override.vm.synced_folder ".", "/vagrant/", mount_options: ["dir_mode=777"]
    override.vm.synced_folder "maposmatic", "/home/maposmatic", mount_options: ["dir_mode=777"]
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
  config.disksize.size =  ENV.fetch("DISK_SIZE", "150GB")

  unless Vagrant.has_plugin?("vagrant-env")
    raise 'env plugin is not installed - run "vagrant plugin install vagrant-env" first'
  end
  config.env.enable

  config.ssh.forward_x11=true

  config.vm.provision "shell",
    env: {
      "GIT_AUTHOR_NAME":  ENV['GIT_AUTHOR_NAME'],
      "GIT_AUTHOR_EMAIL": ENV['GIT_AUTHOR_EMAIL'],

      "MAPOSMATIC_FORK_URL": ENV.fetch("MAPOSMATIC_FORK_URL", "https://github.com/hholzgra/maposmatic"),
      "MAPOSMATIC_FORK_GIT": ENV.fetch("MAPOSMATIC_FORK_URL", "https://github.com/hholzgra/maposmatic.git"),
      "MAPOSMATIC_FORK_BRANCH": ENV.fetch("MAPOSMATIC_FORK_BRANCH", nil),

      "OCITYSMAP_FORK_URL": ENV.fetch("OCITYSMAP_FORK_URL", "https://githib.com/hholzgra/ocitysmap"),
      "OCITYSMAP_FORK_GIT": ENV.fetch("OCITYSMAP_FORK_URL", "https://github.com/hholzgra/ocitysmap.git"),
      "OCITYSMAP_FORK_BRANCH": ENV.fetch("OCITYSMAP_FORK_BRANCH", nil),

      "BBOX_MAXIMUM_LENGTH_IN_METERS": ENV.fetch("BBOX_MAXIMUM_LENGTH_IN_METERS", 20000),

      "PAPER_MIN_WITH_MM": ENV.fetch("PAPER_MIN_WITH_MM", 100),
      "PAPER_MAX_WITH_MM": ENV.fetch("PAPER_MAX_WITH_MM", 2000),

      "PAPER_MIN_HEIGHT_MM": ENV.fetch("PAPER_MIN_HEIGHT_MM", 100),
      "PAPER_MAX_HEIGHT_MM": ENV.fetch("PAPER_MAX_HEIGHT_MM", 2000),

      "REPLACE_DNS": ENV.fetch("REPLACE_DNS", false),
      "DNS": ENV.fetch("DNS", "8.8.8.8 8.8.4.4"),
    },
    path: "provision.sh"

end
