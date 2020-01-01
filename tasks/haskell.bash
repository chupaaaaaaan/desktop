#!/bin/bash -eux

# 必要なパッケージのインストール(gloss用にfreeglut)
sudo apt-get -y install freeglut3-dev

# haskell stackのインストール
nix-env -iA nixpkgs.stack

# Haskell IDE Engineのインストール
cachix use all-hies
nix-env -iA selection --arg selector 'p: { inherit (p) ghc864 ghc865; }' -f https://github.com/infinisil/all-hies/tarball/master
