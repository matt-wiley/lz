#!/usr/bin/env bash

echo -n "Downloading LZ archive ... "
curl -sL https://github.com/wileymab/landing-zone/blob/master/downloads/lz.zip?raw=true -o lz.zip
echo "done."

echo -n "Unpacking LZ files ... "
unzip -o lz.zip -d ~/.lndr
export LANDER_HOME=~/.lndr
echo "done."

echo -n "Installing executable ... "
ln -sf ~/.lndr/bin/lndr.sh /usr/local/bin/lndr
echo "done."

echo -n "Initializing zone registry ... "
mkdir -p ${LANDER_HOME}/zones || true
echo "done."

echo -n "Initalizing zone loader in .bashrc ... "
echo "" >> ~/.bashrc
echo "# LZ Loader" >> ~/.bashrc
echo "export LANDER_HOME=~/.lndr" >> ~/.bashrc
echo "source ${LANDER_HOME}/bin/bashrc-hook.sh" >> ~/.bashrc
echo "done."