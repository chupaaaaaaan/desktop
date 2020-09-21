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
        sudo apt-get -y purge firefox thunderbird

        # aptで入らないパッケージのインストール
        sudo snap install chromium
        sudo snap install discord
        sudo snap install libreoffice

        # ソフトウェアセンターからインストールすると日本語入力できな問題があるので、debパッケージから直接インストールする。
        #sudo snap install slack --classic
        SLACK_VERSION=4.7.0 &&
            curl -sSLO https://downloads.slack-edge.com/linux_releases/slack-desktop-${SLACK_VERSION}-amd64.deb &&
            sudo dpkg -i slack-desktop-${SLACK_VERSION}-amd64.deb &&
            rm -f slack-desktop-${SLACK_VERSION}-amd64.deb
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


: Haskellインストール_stack ||
    {
        # 必要なパッケージのインストール
        sudo apt-get -y install \
             freeglut3-dev \
             libcurl4-openssl-dev

        # haskell stack/cabalのインストール
        # よく使うライブラリも入れておく(AtCoder用含む)
        sudo rm /usr/local/bin/stack -rf &&
            curl -sSL https://get.haskellstack.org/ | sh &&
            stack setup &&
            stack build \
                  unicode-show \
                  QuickCheck \
                  array \
                  attoparsec \
                  bytestring \
                  containers \
                  deepseq \
                  extra \
                  fgl \
                  hashable \
                  heaps \
                  integer-logarithms \
                  lens \
                  massiv \
                  mono-traversable \
                  mtl \
                  mutable-containers \
                  mwc-random \
                  parallel \
                  parsec \
                  primitive \
                  psqueues \
                  random \
                  reflection \
                  repa \
                  template-haskell \
                  text \
                  tf-random \
                  transformers \
                  unboxing-vector \
                  unordered-containers \
                  utility-ht \
                  vector \
                  vector-algorithms \
                  vector-th-unbox

        : > $HOME/.bashrc.d/stack
        echo 'eval "$(stack --bash-completion-script stack)"' >> $HOME/.bashrc.d/stack

        : Haskellインストール_HIE不使用（haskell-modeのみ） ||
            {
                # haskell-modeに必要なアプリのインストール
                stack install \
                      hlint \
                      stylish-haskell
                      # cabal-install \
                      # hasktags \
            }

        : Haskellインストール_HIE ||
            {
                sudo apt-get -y install \
                     libicu-dev \
                     libncurses-dev \
                     libgmp-dev \
                     zlib1g-dev
                # stack install cabal-install
                HIEDIR=${HOME}/haskell-ide-engine
                (cd $HOME &&
                     ([ -d "${HIEDIR}" ] || git clone https://github.com/haskell/haskell-ide-engine --recurse-submodules) &&
                     cd ${HIEDIR} &&
                     git fetch &&
                     git checkout 1.4 &&
                     stack install.hs hie-8.8.3 &&
                     stack install.hs hie-8.6.5 &&
                     stack install.hs data)
            }
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
        sudo snap install intellij-idea-ultimate --classic
    }


# 不要パッケージの削除
sudo apt-get -y autoremove

# dotfilesのreset (勝手に.bashrcなどを書き換えてしまうものがあるため)
cd $HOME/dotfiles && git reset --hard
