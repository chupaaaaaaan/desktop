#!/bin/bash

set -e
set -u
set -o pipefail

: 基本設定 ||
    {
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
    }


: 必要なパッケージのインストール（各ソフトウェアで必要なパッケージは、ソフトウェアインストール時に導入） ||
    {
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
             ubuntu-desktop \
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
    }


: dotfileのインストール ||
    {
        # dotfilesのインストール
        if [ -d "$HOME/dotfiles" ]; then
            ( cd $HOME/dotfiles && git pull )
        else
            git clone https://github.com/chupaaaaaaan/dotfiles.git
        fi
        $HOME/dotfiles/deploy.sh
        rm -f $HOME/.profile && ln -s $HOME/.bash_profile $HOME/.profile
    }


: Nixのインストール ||
    {
        # Nixのインストール
        sh <(curl https://nixos.org/nix/install) --no-daemon

        # Nix用プロファイルの作成
        : > $HOME/.bash_profile.d/nix
        echo 'if [ -e /home/vagrant/.nix-profile/etc/profile.d/nix.sh ]; then . /home/vagrant/.nix-profile/etc/profile.d/nix.sh; fi' >> $HOME/.bash_profile.d/nix

        # Nix設定のロード
        . /home/vagrant/.nix-profile/etc/profile.d/nix.sh

        # nixpkgsのアップデート
        nix-channel --update nixpkgs

        # Cachixのインストール
        nix-env -iA cachix -f https://cachix.org/api/v1/install

    }


: Terraformインストール ||
    {
        # pip3のインストール
        sudo apt-get -y install python3-pip

        # awscliのインストール
        pip3 install awscli --upgrade --user

        # terraformのインストール
        curl -sSLO https://releases.hashicorp.com/terraform/0.12.12/terraform_0.12.12_linux_amd64.zip
        unzip terraform_0.12.12_linux_amd64.zip
        rm -f terraform_0.12.12_linux_amd64.zip
        mv -f terraform bin/
    }


: Haskellインストール ||
    {
        # 必要なパッケージのインストール(gloss用にfreeglut)
        sudo apt-get -y install freeglut3-dev

        # haskell stackのインストール
        nix-env -iA nixpkgs.stack

        # Haskell IDE Engineのインストール
        cachix use all-hies
        nix-env -iA selection --arg selector 'p: { inherit (p) ghc864 ghc865; }' -f https://github.com/infinisil/all-hies/tarball/master
    }


: Node.js設定 ||
    {
        # node.jsのインストール
        export NVM_DIR=$HOME/.nvm
        mkdir -p "$NVM_DIR"
        curl -sSL https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash
        [ -s "$NVM_DIR/nvm.sh" ] && \. $NVM_DIR/nvm.sh
        [ -s "$NVM_DIR/bash_completion" ] && \. $NVM_DIR/bash_completion

        nvm install stable
        nvm alias default stable

        # node.js用profileの作成
        : > $HOME/.bash_profile.d/node
        : > $HOME/.bashrc.d/node
        echo 'export NVM_DIR=$HOME/.nvm'                                        >> $HOME/.bash_profile.d/node
        echo '[ -s "$NVM_DIR/nvm.sh" ] && \. $NVM_DIR/nvm.sh'                   >> $HOME/.bash_profile.d/node
        echo '[ -s "$NVM_DIR/nvm.sh" ] && \. $NVM_DIR/nvm.sh'                   >> $HOME/.bashrc.d/node
        echo '[ -s "$NVM_DIR/bash_completion" ] && \. $NVM_DIR/bash_completion' >> $HOME/.bashrc.d/node

        npm config set -g user root

        : Elm設定 ||
            {
                # elmのインストール
                npm install -g http-server elm elm-format elm-oracle elm-test @elm-tooling/elm-language-server
            }
    }


: IntelliJ IDEAインストール ||
    {
        # 必要なパッケージのインストール
        sudo apt-get -y install openjdk-11-jdk maven

        # JDK用profileの作成
        : > $HOME/.bash_profile.d/jdk
        echo 'export JAVA_HOME=$(echo $(readlink -f /usr/bin/javac) | sed -e "s:/bin/javac::")' >> $HOME/.bash_profile.d/jdk

        # Intellij IDEAのインストール
        sudo snap install intellij-idea-community --classic
    }


# 不要パッケージの削除
sudo apt-get -y autoremove

# dotfilesのreset
cd $HOME/dotfiles && git reset --hard
