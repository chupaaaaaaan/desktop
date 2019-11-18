#!/bin/bash -eux

# pip3のインストール
sudo apt-get -y install python3-pip

# awscliのインストール
pip3 install awscli --upgrade --user

# terraformのインストール
curl -sSLO https://releases.hashicorp.com/terraform/0.12.12/terraform_0.12.12_linux_amd64.zip
unzip terraform_0.12.12_linux_amd64.zip
rm -f terraform_0.12.12_linux_amd64.zip
mv -f terraform bin/
