#!/bin/bash

sudo apt-get -y update
sudo apt-get -y install open-vm-tools

cat >> /etc/fstab <<EOF
.host:/vagrant /vagrant fuse.vmhgfs-fuse allow_other 0 0
.host:/Dropbox /home/t-uchida/Dropbox fuse.vmhgfs-fuse allow_other 0 0
EOF
