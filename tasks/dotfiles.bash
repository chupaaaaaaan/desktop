#!/bin/bash -eux

# dotfilesのインストール
if [ -d "$HOME/dotfiles" ]; then
    ( cd $HOME/dotfiles && git pull )
else
    git clone https://github.com/chupaaaaaaan/dotfiles.git
fi
$HOME/dotfiles/deploy.sh
rm -f $HOME/.profile && ln -s $HOME/.bash_profile $HOME/.profile
