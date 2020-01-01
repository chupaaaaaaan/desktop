#!/bin/bash -eux

if [ ! -f $HOME/.aws/credentials ]; then
    exit 0
fi

# eksctl
curl -sSL "https://github.com/weaveworks/eksctl/releases/download/latest_release/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
mv /tmp/eksctl $HOME/bin/
chmod 755 $HOME/bin/eksctl

# minikube with kvm2 vm-driver.
# https://kubernetes.io/docs/setup/learning-environment/minikube/
# https://kubernetes.io/docs/tasks/tools/install-minikube/

#yum install qemu-kvm libvirt libvirt-python libguestfs-tools virt-install
#systemctl start libvirtd.service
#systemctl enable libvirtd.service
#modprobe fuse
#sh -c 'echo fuse > /etc/modules-load.d/fuse.conf'
#usermod -aG libvirt t-uchida
curl -sSLo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
mv $HOME/minikube $HOME/bin/
chmod 755 $HOME/bin/minikube

# kubectl
curl -sSLO https://storage.googleapis.com/kubernetes-release/release/$(curl -sSL https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
mv $HOME/kubectl $HOME/bin/
chmod 755 $HOME/bin/kubectl
