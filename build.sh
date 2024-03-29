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

    }
: 地域設定 ||
    {
        # タイムゾーンの設定
        sudo timedatectl set-timezone Asia/Tokyo

        # ロケールの設定
        sudo localectl set-locale LANG=ja_JP.UTF-8 LANGUAGE="ja_JP:ja" 
    }


: 日本語環境 ||
    {
        wget -q https://www.ubuntulinux.jp/ubuntu-ja-archive-keyring.gpg -O- | sudo apt-key add -
        wget -q https://www.ubuntulinux.jp/ubuntu-jp-ppa-keyring.gpg -O- | sudo apt-key add -
        sudo wget https://www.ubuntulinux.jp/sources.list.d/focal.list -O /etc/apt/sources.list.d/ubuntu-ja.list
        sudo apt-get update
        sudo apt-get -y install ubuntu-defaults-ja
    }



: 必要なパッケージのインストール（各ソフトウェアで必要なパッケージは、ソフトウェアインストール時に導入） ||
    {
        sudo apt-get update
        sudo apt-get -y upgrade
        sudo apt-get -y dist-upgrade
        sudo apt-get -y install \
             jq \
             git \
             curl \
             unzip \
             tzdata \
             bash-completion
        # ifupdown

        # emacs26のインストール
        # 20.04からは標準で提供されているっぽいので、リポジトリ追加は不要。
        # sudo add-apt-repository -y ppa:kelleyk/emacs
        # sudo apt-get update
        # sudo apt-get -y install emacs26
        sudo apt-get -y install emacs
    }


: dotfileのインストール ||
    {
        if [ -d "$HOME/dotfiles" ]; then
            ( cd $HOME/dotfiles && git pull )
        else
            ( cd $HOME && git clone https://github.com/chupaaaaaaan/dotfiles.git )
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
        curl -sSL -o /tmp/terraform.zip https://releases.hashicorp.com/terraform/0.13.5/terraform_0.13.5_linux_amd64.zip
        unzip -u -d /tmp /tmp/terraform.zip
        sudo mv -f /tmp/terraform /usr/local/bin/
    }


: Haskellインストール ||
    {
        # 必要なパッケージのインストール
        sudo apt-get -y install \
             build-essential \
             zlib1g-dev \
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
        BOOTSTRAP_HASKELL_NONINTERACTIVE=1 curl -sSL https://get-ghcup.haskell.org | sh
        . $HOME/.ghcup/env

        : > $HOME/.bash_profile.d/ghcup
	echo '[ -f "$HOME/.ghcup/env" ] && \. $HOME/.ghcup/env'  >> $HOME/.bash_profile.d/ghcup

        # HLSインストール
        ghcup install hls latest

        # Stackインストール
        ghcup install stack latest
        stack config set system-ghc --global true
        : > $HOME/.bashrc.d/stack
        echo 'eval "$(stack --bash-completion-script stack)"' >> $HOME/.bashrc.d/stack

        cabal update

        : GHC 8.8.4環境のセットアップ （AtCoder用） ||
            {
                # Windowsでは8.8.3がうまく動かないので、最も近いバージョンをインストールする
                ghcup install ghc 8.8.4 --set
            }

        : アプリ・ライブラリのインストール ||
            {
                # アプリケーションのインストール
                # cabal install --overwrite-policy=always \
                cabal install hakyll implicit-hie

                # ライブラリのインストール
                cabal install --lib pretty-simple
            }
    }


: Node.jsインストール ||
    {
        export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
        mkdir -p "$NVM_DIR"
        curl -sSL https://raw.githubusercontent.com/creationix/nvm/v0.39.1/install.sh | bash
        [ -s "$NVM_DIR/nvm.sh" ] && \. $NVM_DIR/nvm.sh
        [ -s "$NVM_DIR/bash_completion" ] && \. $NVM_DIR/bash_completion

        nvm install 'lts/*' --reinstall-packages-from=current
        nvm alias default lts/gallium

        : > $HOME/.bashrc.d/node
        echo 'export NVM_DIR=$HOME/.nvm'                                        >> $HOME/.bashrc.d/node
        echo '[ -s "$NVM_DIR/nvm.sh" ] && \. $NVM_DIR/nvm.sh'                   >> $HOME/.bashrc.d/node
        echo '[ -s "$NVM_DIR/bash_completion" ] && \. $NVM_DIR/bash_completion' >> $HOME/.bashrc.d/node

        npm config set -g user root


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
    }


: Java環境インストール ||
    {
        sudo apt-get -y install \
             openjdk-11-jdk \
             maven

        : > $HOME/.bashrc.d/jdk
        echo '# export JAVA_HOME=`/usr/libexec/java_home -v 1.8`'                               >> $HOME/.bashrc.d/jdk
        echo '# export JAVA_HOME=`/usr/libexec/java_home -v 11`'                                >> $HOME/.bashrc.d/jdk
        echo 'export JAVA_HOME=$(echo $(readlink -f /usr/bin/javac) | sed -e "s:/bin/javac::")' >> $HOME/.bashrc.d/jdk
    }


: デスクトップ環境のインストール ||
    {
        # フォント、デスクトップ環境のインストール
        sudo apt-get update
        sudo apt-get -y install \
             fonts-takao \
             fonts-ricty-diminished \
             ubuntu-desktop-minimal

        # firefox, thunderbirdは不要なので削除
        #sudo apt-get -y purge firefox thunderbird

        # aptで入らないデスクトップアプリのインストール
        sudo snap install discord
        sudo snap install libreoffice
        sudo snap install todoist
        sudo snap install drawio

        # snapでインストールしたブラウザがデフォルトブラウザになっていると、JetBrains ToolboxのOAuthに失敗するみたいなので、debパッケージから直接インストールする。
        # せっかくなのでchromiumからchromeに替える。
        # 参考: https://toolbox-support.jetbrains.com/hc/en-us/community/posts/360004301099-Toolbox-Login-not-working-in-Linux
        #sudo snap install chromium
        curl -sSL -o /tmp/google-chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
        sudo dpkg -i /tmp/google-chrome.deb

        # ソフトウェアセンターからインストールすると日本語入力できない問題があるので、debパッケージから直接インストールする。
        #snap install slack --classic
        curl -sSL -o /tmp/slack.deb https://downloads.slack-edge.com/linux_releases/slack-desktop-4.15.0-amd64.deb
        sudo dpkg -i /tmp/slack.deb

        # JetBrains製品の管理はToolboxの使用が推奨されているので、snapによるインストールは使用しない。
        #sudo snap install intellij-idea-community --classic
        curl -sSL -o /tmp/jetbrains-toolbox.tar.gz https://download.jetbrains.com/toolbox/jetbrains-toolbox-1.20.8352.tar.gz
        ( cd /tmp && tar xzvf jetbrains-toolbox.tar.gz && $(find /tmp -type d -name "jetbrains-toolbox*" 2> /dev/null | head -n 1)/jetbrains-toolbox )
    }


# 不要パッケージの削除
sudo apt-get -y autoremove

# dotfilesのreset (勝手に.bashrcなどを書き換えてしまうものがあるため)
cd $HOME/dotfiles && git reset --hard
