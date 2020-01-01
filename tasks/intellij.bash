#!/bin/bash -eux

# 必要なパッケージのインストール
sudo apt-get -y install openjdk-11-jdk maven

# JDK用profileの作成
: > $HOME/.bash_profile.d/jdk
echo 'export JAVA_HOME=$(echo $(readlink -f /usr/bin/javac) | sed -e "s:/bin/javac::")' >> $HOME/.bash_profile.d/jdk

# Intellij IDEAのインストール
sudo snap install intellij-idea-community --classic
