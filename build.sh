#!/bin/bash

# packages
sudo add-apt-repository -y ppa:kelleyk/emacs
curl -s https://www.ubuntulinux.jp/ubuntu-ja-archive-keyring.gpg | sudo apt-key add -
curl -s https://www.ubuntulinux.jp/ubuntu-jp-ppa-keyring.gpg | sudo apt-key add -
sudo curl -s -o /etc/apt/sources.list.d/ubuntu-ja.list https://www.ubuntulinux.jp/sources.list.d/bionic.list
sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get -y dist-upgrade
sudo apt-get -y install \
        git \
        curl \
        tzdata \
        emacs26 \
        openjdk-8-jdk \
        ubuntu-desktop \
        ubuntu-defaults-ja \
        chromium-browser \
        nautilus-dropbox

sudo apt-get -y purge firefox

mkdir -p $HOME/bin $HOME/.local/bin
rm -f $HOME/.profile

# timezone
#sudo ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
sudo timedatectl set-timezone Asia/Tokyo

# locale
sudo localectl set-locale LANG=ja_JP.UTF-8 LANGUAGE="ja_JP:ja" 

# dotfiles
git clone https://github.com/chupaaaaaaan/dotfiles.git
./dotfiles/deploy.sh

# haskell stack
curl -sSL https://get.haskellstack.org/ | sh

# haskell ide engine
# https://github.com/haskell/haskell-ide-engine
sudo apt-get -y install libicu-dev libtinfo-dev libgmp-dev
git clone https://github.com/haskell/haskell-ide-engine --recurse-submodules
cd haskell-ide-engine
stack ./install.hs hie-8.6.4
stack ./install.hs build-doc   

