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
        sudo wget https://www.ubuntulinux.jp/sources.list.d/focal.list -O /etc/apt/sources.list.d/ubuntu-ja.list
        sudo apt-get update
        sudo apt-get -y upgrade
        sudo apt-get -y dist-upgrade
        sudo apt-get -y install \
             jq \
             git \
             curl \
             unzip \
             tzdata \
             fonts-takao \
             bash-completion \
             ubuntu-defaults-ja \
             ubuntu-desktop-minimal \
             fonts-ricty-diminished
        # ifupdown

        # emacs26のインストール
        # 20.04からは標準で提供されているっぽいので、リポジトリ追加は不要。
        # sudo add-apt-repository -y ppa:kelleyk/emacs
        # sudo apt-get update
        # sudo apt-get -y install emacs26
        sudo apt-get -y install emacs

        # firefox, thunderbirdは不要なので削除
        #sudo apt-get -y purge firefox thunderbird

        # aptで入らないパッケージのインストール
        sudo snap install chromium
        sudo snap install discord
        sudo snap install libreoffice

        # ソフトウェアセンターからインストールすると日本語入力できない問題があるので、debパッケージから直接インストールする。
        #snap install slack --classic
        curl -sSL -o /tmp/slack.deb https://downloads.slack-edge.com/linux_releases/slack-desktop-4.7.0-amd64.deb
        sudo dpkg -i /tmp/slack.deb
    }


: dotfileのインストール ||
    {
        if [ -d "$HOME/dotfiles" ]; then
            ( cd $HOME/dotfiles && git pull )
        else
            git clone https://github.com/chupaaaaaaan/dotfiles.git
        fi
        $HOME/dotfiles/deploy.sh

        # Ubuntuの場合は.profileのみ読み込まれるため、.bash_profileのシンボリックリンクにする。
        rm -f $HOME/.profile
        ln -s $HOME/.bash_profile $HOME/.profile
    }


: AWS CLI v2のインストール ||
    {
        curl -sSL -o /tmp/awscliv2.zip https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip
        unzip -u -d /tmp /tmp/awscliv2.zip
        sudo /tmp/aws/install --update
    }


: Terraformインストール ||
    {
        curl -sSL -o /tmp/terraform.zip https://releases.hashicorp.com/terraform/0.13.4/terraform_0.13.4_linux_amd64.zip
        unzip -u -d /tmp /tmp/terraform.zip
        sudo mv -f /tmp/terraform /usr/local/bin/
    }


: Haskellインストール ||
    {
        # 必要なパッケージのインストール
        sudo apt-get -y install \
             build-essential \
             libffi-dev \
             libffi7 \
             libgmp-dev \
             libgmp10 \
             libncurses-dev \
             libncurses5 \
             libtinfo6 \
             freeglut3-dev \
             libcurl4-openssl-dev

        # ghcupのインストール
        export BOOTSTRAP_HASKELL_NONINTERACTIVE=1
        curl -sSL https://get-ghcup.haskell.org | sh
        . $HOME/.ghcup/env

        : > $HOME/.bash_profile.d/ghcup
	echo '[ -f "$HOME/.ghcup/env" ] && \. $HOME/.ghcup/env'  >> $HOME/.bash_profile.d/ghcup

        # ghcupにより、ghcをインストール
        ghcup install ghc 8.8.4
        ghcup install ghc 8.8.3
        ghcup install ghc 8.8.2
        ghcup install ghc 8.6.5
        ghcup install ghc 8.6.4

        # ghcupにより、haskell-language-serverをインストール
        ghcup install hls latest
    }


: Haskellインストール_パッケージ ||
    {
        cabal update

        # アプリケーションのインストール
        ghcup set ghc 8.8.4
        cabal install --overwrite-policy=always \
              hakyll \
              hlint \
              stylish-haskell

        # ライブラリのインストール
        ghcup set ghc 8.8.4
        cabal install --lib \
              unicode-show \
              implicit-hie

        # ライブラリのインストール (AtCoder用)
        ghcup set ghc 8.8.3
        cabal install --lib \
              QuickCheck-2.13.2 \
              array-0.5.4.0 \
              attoparsec-0.13.2.3 \
              bytestring-0.10.10.0 \
              containers-0.6.2.1 \
              deepseq-1.4.4.0 \
              extra-1.7.1 \
              fgl-5.7.0.2 \
              hashable-1.3.0.0 \
              heaps-0.3.6.1 \
              integer-logarithms-1.0.3 \
              lens-4.19.1 \
              massiv-0.5.1.0 \
              mono-traversable-1.0.15.1 \
              mtl-2.2.2 \
              mutable-containers-0.3.4 \
              mwc-random-0.14.0.0 \
              parallel-3.2.2.0 \
              parsec-3.1.14.0 \
              primitive-0.7.0.1 \
              psqueues-0.2.7.2 \
              random-1.1 \
              reflection-2.1.5 \
              repa-3.4.1.4 \
              template-haskell-2.15.0.0 \
              text-1.2.4.0 \
              tf-random-0.5 \
              transformers-0.5.6.2 \
              unboxing-vector-0.1.1.0 \
              unordered-containers-0.2.10.0 \
              utility-ht-0.0.15 \
              vector-0.12.1.2 \
              vector-algorithms-0.8.0.3 \
              vector-th-unbox-0.2.1.7

        ghcup set ghc 8.8.4
    }

: Haskellインストール_stack ||
    {
        sudo rm /usr/local/bin/stack -f
        curl -sSL https://get.haskellstack.org/ | sh
        stack config set system-ghc --global true
        stack setup

        : > $HOME/.bashrc.d/stack
        echo 'eval "$(stack --bash-completion-script stack)"' >> $HOME/.bashrc.d/stack
    }


: Node.jsインストール ||
    {
        export NVM_DIR=$HOME/.nvm
        mkdir -p "$NVM_DIR"
        curl -sSL https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash
        [ -s "$NVM_DIR/nvm.sh" ] && \. $NVM_DIR/nvm.sh
        [ -s "$NVM_DIR/bash_completion" ] && \. $NVM_DIR/bash_completion

        nvm install stable
        nvm alias default stable

        : > $HOME/.bash_profile.d/node
        : > $HOME/.bashrc.d/node
        echo 'export NVM_DIR=$HOME/.nvm'                                        >> $HOME/.bash_profile.d/node
        echo '[ -s "$NVM_DIR/nvm.sh" ] && \. $NVM_DIR/nvm.sh'                   >> $HOME/.bash_profile.d/node
        echo '[ -s "$NVM_DIR/nvm.sh" ] && \. $NVM_DIR/nvm.sh'                   >> $HOME/.bashrc.d/node
        echo '[ -s "$NVM_DIR/bash_completion" ] && \. $NVM_DIR/bash_completion' >> $HOME/.bashrc.d/node

        npm config set -g user root
    }


: Elmインストール ||
    {
        npm install -g \
            http-server \
            elm \
            elm-format \
            elm-oracle \
            elm-test \
            @elm-tooling/elm-language-server
    }


: Java環境インストール ||
    {
        sudo apt-get -y install \
             openjdk-11-jdk \
             maven

        : > $HOME/.bash_profile.d/jdk
        echo '# export JAVA_HOME=`/usr/libexec/java_home -v 1.8`'
        echo '# export JAVA_HOME=`/usr/libexec/java_home -v 11`'
        echo 'export JAVA_HOME=$(echo $(readlink -f /usr/bin/javac) | sed -e "s:/bin/javac::")' >> $HOME/.bash_profile.d/jdk
    }


: IntelliJ IDEAインストール ||
    {
        sudo snap install intellij-idea-community --classic
    }


# 不要パッケージの削除
sudo apt-get -y autoremove

# dotfilesのreset (勝手に.bashrcなどを書き換えてしまうものがあるため)
cd $HOME/dotfiles && git reset --hard
