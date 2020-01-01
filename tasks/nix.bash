#!/bin/bash -eux

# Nixのインストール
sh <(curl https://nixos.org/nix/install) --daemon

# nixpkgsのアップデート
nix-channel --update nixpkgs

# Cachixのインストール
nix-env -iA cachix -f https://cachix.org/api/v1/install

# vagrantユーザでもnix-daemonが使えるようにする (こうしないと、Cachixをvagrantユーザが使えない)
echo "trusted-users = root $USER" | sudo tee -a /etc/nix/nix.conf
sudo pkill nix-daemon
