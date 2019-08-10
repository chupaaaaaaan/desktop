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
        ifupdown \
        openjdk-8-jdk \
        ubuntu-desktop \
        ubuntu-defaults-ja \
        chromium-browser

sudo apt-get -y purge firefox thunderbird
sudo apt-get -y autoremove

mkdir -p $HOME/bin $HOME/.local/bin
mkdir -p $HOME/.bash_profile.d $HOME/.bashrc.d

# timezone
#sudo ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
sudo timedatectl set-timezone Asia/Tokyo

# locale
sudo localectl set-locale LANG=ja_JP.UTF-8 LANGUAGE="ja_JP:ja" 

# dotfiles
git clone https://github.com/chupaaaaaaan/dotfiles.git
./dotfiles/deploy.sh
rm -f $HOME/.profile && ln -s $HOME/.bash_profile $HOME/.profile

# haskell stack
curl -sSL https://get.haskellstack.org/ | sh

# haskell ide engine
# https://github.com/haskell/haskell-ide-engine
sudo apt-get -y install libicu-dev libtinfo-dev libgmp-dev
git clone https://github.com/haskell/haskell-ide-engine --recurse-submodules
cd haskell-ide-engine
stack ./install.hs hie-8.6.4
stack ./install.hs build-data


# node.js
export NVM_DIR=$HOME/.nvm
mkdir -p "$NVM_DIR"
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash
[ -s "$NVM_DIR/nvm.sh" ] && \. $NVM_DIR/nvm.sh
[ -s "$NVM_DIR/bash_completion" ] && \. $NVM_DIR/bash_completion

nvm install stable
nvm alias default stable


# profile setting of node
echo 'export NVM_DIR=$HOME/.nvm'                                        >  $HOME/.bash_profile.d/node
echo '[ -s "$NVM_DIR/nvm.sh" ] && \. $NVM_DIR/nvm.sh'                   >> $HOME/.bash_profile.d/node
echo '[ -s "$NVM_DIR/nvm.sh" ] && \. $NVM_DIR/nvm.sh'                   >  $HOME/.bashrc.d/node
echo '[ -s "$NVM_DIR/bash_completion" ] && \. $NVM_DIR/bash_completion' >> $HOME/.bashrc.d/node


# elm
npm config set -g user root
npm install -g http-server elm elm-format elm-oracle elm-test @elm-tooling/elm-language-server
