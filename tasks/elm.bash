#!/bin/bash -eux


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


# elmのインストール
npm config set -g user root
npm install -g http-server elm elm-format elm-oracle elm-test @elm-tooling/elm-language-server
