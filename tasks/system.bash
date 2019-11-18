#!/bin/bash -eux

# 共通で使用するディレクトリの作成
mkdir -p $HOME/bin
mkdir -p $HOME/.local/bin
mkdir -p $HOME/.local/share/applications/
mkdir -p $HOME/.bash_profile.d
mkdir -p $HOME/.bashrc.d

# タイムゾーンの設定
sudo timedatectl set-timezone Asia/Tokyo

# ロケールの設定
sudo localectl set-locale LANG=ja_JP.UTF-8 LANGUAGE="ja_JP:ja" 

