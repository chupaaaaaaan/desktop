#!/bin/bash -eux

# 必要なパッケージのインストール（各ソフトウェアで必要なパッケージは、ソフトウェアインストール時に導入）
wget -q https://www.ubuntulinux.jp/ubuntu-ja-archive-keyring.gpg -O- | sudo apt-key add -
wget -q https://www.ubuntulinux.jp/ubuntu-jp-ppa-keyring.gpg -O- | sudo apt-key add -
sudo wget https://www.ubuntulinux.jp/sources.list.d/bionic.list -O /etc/apt/sources.list.d/ubuntu-ja.list
sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get -y install \
     git \
     curl \
     unzip \
     tzdata \
     lubuntu-desktop \
     ubuntu-defaults-ja \
     fonts-ricty-diminished \
     chromium-browser
# ifupdown

# emacs26のインストール
sudo add-apt-repository -y ppa:kelleyk/emacs
curl -sSL https://www.ubuntulinux.jp/ubuntu-ja-archive-keyring.gpg | sudo apt-key add -
curl -sSL https://www.ubuntulinux.jp/ubuntu-jp-ppa-keyring.gpg | sudo apt-key add -
sudo curl -sSL -o /etc/apt/sources.list.d/ubuntu-ja.list https://www.ubuntulinux.jp/sources.list.d/bionic.list
sudo apt-get -y install emacs26

# firefox, thunderbirdは不要なので削除
sudo apt-get -y purge firefox thunderbird

# aptで入らないパッケージのインストール
sudo snap install discord
sudo snap install slack --classic
