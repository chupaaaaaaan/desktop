#!/bin/bash -eux

# 必要なパッケージのインストール
sudo apt-get -y install openjdk-8-jdk maven

# JDK用profileの作成
: > $HOME/.bash_profile.d/jdk
echo 'export JAVA_HOME=$(echo $(readlink -f /usr/bin/javac) | sed -e "s:/bin/javac::")' >> $HOME/.bash_profile.d/jdk

# Spring Tool Suite 4のインストール
if [ ! -f $HOME/sts-4.4.1.RELEASE/SpringToolSuite4.ini.orig ]; then
    curl -sSL https://download.springsource.com/release/STS4/4.4.1.RELEASE/dist/e4.13/spring-tool-suite-4-4.4.1.RELEASE-e4.13.0-linux.gtk.x86_64.tar.gz | tar xzvf -
    cp $HOME/sts-4.4.1.RELEASE/SpringToolSuite4.ini{,.orig} && chmod -w $HOME/sts-4.4.1.RELEASE/SpringToolSuite4.ini.orig
fi

# STS4用デスクトップエントリの作成
cat <<EOF > $HOME/.local/share/applications/SpringToolSuite4.desktop
[Desktop Entry]
Type=Application
Categories=Development;
Encoding=UTF-8
Name=SpringToolSuite4
Comment=SpringToolSuite4
Exec=$HOME/sts-4.4.1.RELEASE/SpringToolSuite4
Icon=$HOME/sts-4.4.1.RELEASE/icon.xpm
Terminal=false
EOF

# pleiadesプラグインのインストール
curl -sSLO https://ftp.jaist.ac.jp/pub/mergedoc/pleiades/build/stable/pleiades.zip
unzip -d pleiades pleiades.zip
/bin/cp -rf $HOME/pleiades/{features,plugins} $HOME/sts-4.4.1.RELEASE
rm -rf $HOME/pleiades{,.zip}

# lombokのインストール
curl -sSLO https://projectlombok.org/downloads/lombok.jar
mv $HOME/lombok.jar $HOME/sts-4.4.1.RELEASE/plugins/

# SpringToolSuite4.iniの設定を編集
/bin/cp $HOME/sts-4.4.1.RELEASE/SpringToolSuite4.ini{.orig,} && chmod u+w $HOME/sts-4.4.1.RELEASE/SpringToolSuite4.ini
## pleiades
echo '-Xverify:none' >> $HOME/sts-4.4.1.RELEASE/SpringToolSuite4.ini
echo '-javaagent:'$HOME'/sts-4.4.1.RELEASE/plugins/jp.sourceforge.mergedoc.pleiades/pleiades.jar' >> $HOME/sts-4.4.1.RELEASE/SpringToolSuite4.ini
## lombok
echo '-javaagent:'$HOME'/sts-4.4.1.RELEASE/plugins/lombok.jar' >> $HOME/sts-4.4.1.RELEASE/SpringToolSuite4.ini
