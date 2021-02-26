# -*- mode: ruby -*-
# vi: set ft=ruby :

def bool(obj)
  obj.to_s.downcase == "true"
end

Vagrant.configure(2) do |config|
  # *** PLUGINS ***
  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :box
    config.cache.synced_folder_opts = {
      owner: "_apt"
    }
  end

  unless Vagrant.has_plugin?("vagrant-env")
    raise 'env plugin is not installed - run "vagrant plugin install vagrant-env" first'
  end
  config.env.enable

  unless Vagrant.has_plugin?("vagrant-vbguest")
    raise 'vbguest plugin is not installed - run "vagrant plugin install vagrant-vbguest" first'
  end

  if Vagrant.has_plugin?("vagrant-vbguest")
    config.vbguest.auto_update = bool(ENV.fetch("VAGRANT_VBGUEST_AUTO_UPDATE", true))
  end

  unless Vagrant.has_plugin?("vagrant-disksize")
    raise 'disksize plugin is not installed - run "vagrant plugin install vagrant-disksize" first'
  end
  config.disksize.size =  ENV.fetch("DISK_SIZE", "150GB")


  # *** CONFIG ***
  # *** CONFIG > COMMON ***

  config.vm.box = "generic/ubuntu2004"

  config.vm.network "forwarded_port", guest: 80, host: ENV.fetch("HOST_PORT", 8000)

  config.vm.boot_timeout = ENV.fetch("VM_BOOT_TIMEOUT", 600).to_i
  config.ssh.forward_agent = true
  config.ssh.forward_x11 = true

  config.vm.provision "shell",
    env: {
      "GIT_AUTHOR_NAME":  ENV['GIT_AUTHOR_NAME'],
      "GIT_AUTHOR_EMAIL": ENV['GIT_AUTHOR_EMAIL'],

      "MAPOSMATIC_FORK_URL": ENV.fetch("MAPOSMATIC_FORK_URL", "https://github.com/hholzgra/maposmatic"),
      "MAPOSMATIC_FORK_GIT": ENV.fetch("MAPOSMATIC_FORK_GIT", "https://github.com/hholzgra/maposmatic.git"),
      "MAPOSMATIC_FORK_BRANCH": ENV.fetch("MAPOSMATIC_FORK_BRANCH", nil),

      "OCITYSMAP_FORK_URL": ENV.fetch("OCITYSMAP_FORK_URL", "https://githib.com/hholzgra/ocitysmap"),
      "OCITYSMAP_FORK_GIT": ENV.fetch("OCITYSMAP_FORK_GIT", "https://github.com/hholzgra/ocitysmap.git"),
      "OCITYSMAP_FORK_BRANCH": ENV.fetch("OCITYSMAP_FORK_BRANCH", nil),

      "BBOX_MAXIMUM_LENGTH_IN_METERS": ENV.fetch("BBOX_MAXIMUM_LENGTH_IN_METERS", 20000).to_i,

      "PAPER_MIN_WITH_MM": ENV.fetch("PAPER_MIN_WITH_MM", 100).to_i,
      "PAPER_MAX_WITH_MM": ENV.fetch("PAPER_MAX_WITH_MM", 2000).to_i,

      "PAPER_MIN_HEIGHT_MM": ENV.fetch("PAPER_MIN_HEIGHT_MM", 100).to_i,
      "PAPER_MAX_HEIGHT_MM": ENV.fetch("PAPER_MAX_HEIGHT_MM", 2000).to_i,

      "REPLACE_DNS": bool(ENV.fetch("REPLACE_DNS", false)),
      "DNS": ENV.fetch("DNS", "8.8.8.8 8.8.4.4"),
    },
    path: "provision.sh"


  # *** CONFIG > PROVIDERS ***
  # *** CONFIG > PROVIDERS > Virtual Box ***

  config.vm.provider "virtualbox" do |vb, override|
    # vb.gui = true
    vb.name = "maposmatic"
    vb.memory = ENV.fetch("VM_MEMORY", 3072).to_i
    vb.cpus   = ENV.fetch("VM_CPUS", 2).to_i

    override.vm.synced_folder ".", "/vagrant/", mount_options: ["dmode=777"]
    override.vm.synced_folder "maposmatic", "/home/maposmatic", mount_options: ["dmode=777"]
  end


  # *** CONFIG > PROVIDERS > Hyper-V ***

  config.vm.provider "hyperv" do |h, override|
    h.memory = ENV.fetch("VM_MEMORY", 3072).to_i
    h.maxmemory = ENV.fetch("VM_MEMORY", 3072).to_i
    h.cpus = ENV.fetch("VM_CPUS", 2).to_i

    override.vm.synced_folder ".", "/vagrant/", mount_options: ["dir_mode=777"]
    override.vm.synced_folder "maposmatic", "/home/maposmatic", mount_options: ["dir_mode=777"]
  end

end
