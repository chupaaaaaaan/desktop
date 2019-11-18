#!/bin/bash

##
## @(#) 開発環境のセットアップスクリプトを実行する
##

set -e
set -u
set -o pipefail

# コマンドを表示して実行
run () {
    echo -e "\033[34m[localhost]$ $1\033[m" >&2
    eval $1
}

# コピーするファイル
files='{tasks.txt,tasks}'

# ファイルのコピー
run "cp -rf $HOME/Dropbox/desktop/$files $HOME"

# スクリプト実行
cat <<'HERE' | run "sh"
set -eu
cd $HOME
grep -v -e '^[[:space:]]*#' -e '^[[:space:]]*$' tasks.txt | while read script; do
    echo >&2
    echo "bash tasks/$script" >&2
    bash tasks/$script
done
HERE

# ファイルの削除
run "rm -rf $files"

# dotfilesのreset
run "( cd $HOME/dotfiles && git reset --hard )"
