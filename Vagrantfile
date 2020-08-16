# coding: utf-8
Vagrant.configure(2) do |config|

  config.vm.box = "ubuntu/focal64"

  config.disksize.size = '256GB'

  config.vm.define "nodeV1" do |node|
    node.vm.provider "virtualbox" do |vb|
      vb.name    = "develop"
      vb.cpus    = 2
      vb.memory  = 10240
      vb.gui     = true
      vb.customize [ "modifyvm", :id, "--natdnsproxy1", "on" ]
      vb.customize [ "modifyvm", :id, "--natdnshostresolver1", "on" ]
      vb.customize [ "modifyvm", :id, "--nic1", "nat" ]
      vb.customize [ "modifyvm", :id, "--nictype1", "virtio" ]
      vb.customize [ "modifyvm", :id, "--vram", "256" ]
      vb.customize [ "modifyvm", :id, "--clipboard", "bidirectional" ]
      vb.customize [ "modifyvm", :id, "--draganddrop", "bidirectional" ]
      vb.customize [ "modifyvm", :id, "--ioapic", "on" ]
      vb.customize [ "modifyvm", :id, "--uart1", "0x3F8", "4" ]
      vb.customize [ "modifyvm", :id, "--uartmode1", "file", File::NULL ]
    end

    node.vm.hostname = "develop"

    # node.vm.network "private_network", ip: "192.168.23.1", virtualbox__intnet: "intnet", nic_type: "virtio"
    node.vm.network "public_network", ip: "192.168.3.129", nic_type: "virtio"
    node.vm.network "private_network", ip: "192.168.56.201", nic_type: "virtio"

    node.vm.provision "shell", path: "./swap.sh", args: ['10240']
    node.vm.provision "shell", path: "./build.sh", privileged: false

    node.vm.synced_folder "#{ENV['HOMEPATH']}\\Dropbox"                 , "/home/vagrant/Dropbox", mount_options: ['dmode=755','fmode=644']
    node.vm.synced_folder "#{ENV['HOMEPATH']}\\Documents\\Sync\\vagrant", "/vagrant"             , mount_options: ['dmode=755','fmode=644']
    # node.vm.synced_folder "#{ENV['HOMEPATH']}\\Documents\\Sync\\project", "/home/vagrant/project", mount_options: ['dmode=755','fmode=755']
  end

end
