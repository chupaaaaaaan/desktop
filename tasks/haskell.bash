#!/bin/bash -eux

# 必要なパッケージのインストール
# gloss, hie
sudo apt-get -y install \
     freeglut3-dev \
     libicu-dev \
     libtinfo-dev \
     libgmp-dev

# haskell stackのインストール
curl -sSL https://get.haskellstack.org/ | sh

# haskell ide engineのインストール
if [ -d "$HOME/haskell-ide-engine" ]; then
    ( cd $HOME/haskell-ide-engine && git pull )
else
    git clone https://github.com/haskell/haskell-ide-engine --recurse-submodules
fi
( cd $HOME/haskell-ide-engine &&
      stack ./install.hs stack-hie-8.6.4 &&
      stack ./install.hs stack-build-data )

