# coding: utf-8
Vagrant.configure(2) do |config|

  config.vm.box = "ubuntu/bionic64"

  config.disksize.size = '256GB'

  config.vm.define "nodeV1" do |node|
    node.vm.provider "virtualbox" do |vb|
      vb.name    = "develop"
      vb.cpus    = 3
      vb.memory  = 10240
      vb.gui     = true
      vb.customize [ "modifyvm"              , :id,
                     "--natdnsproxy1"        , "on",
                     "--natdnshostresolver1" , "on",
                     "--nic1"                , "nat",
                     "--nictype1"            , "virtio",
                     "--vram"                , "256",
                     "--clipboard"           , "bidirectional",
                     "--draganddrop"         , "bidirectional",
                     "--ioapic"              , "on"
                   ]
    end

    node.vm.hostname = "develop"

    # node.vm.network "private_network", ip: "192.168.23.1", virtualbox__intnet: "intnet", nic_type: "virtio"
    node.vm.network "public_network", ip: "192.168.3.129", nic_type: "virtio"

    node.vm.provision "shell", path: "./swap.sh", args: ['10240']
    node.vm.provision "shell", path: "./build.sh", privileged: false

    node.vm.synced_folder "#{ENV['HOMEPATH']}\\Dropbox"                 , "/home/vagrant/Dropbox", mount_options: ['dmode=755','fmode=644']
    node.vm.synced_folder "#{ENV['HOMEPATH']}\\Documents\\Sync\\vagrant", "/vagrant"             , mount_options: ['dmode=755','fmode=644']
    node.vm.synced_folder "#{ENV['HOMEPATH']}\\Documents\\Sync\\project", "/home/vagrant/project", mount_options: ['dmode=755','fmode=755']
  end

end
