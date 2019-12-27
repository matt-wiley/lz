#!/usr/bin/env bash

# curl down the zip of the ./bin dir


echo -n "Unpacking LZ files ... "
unzip lz.zip -d ~/.lndr
echo "done."

echo -n "Installing executable ... "
link ~/.lndr/bin/lndr.sh /usr/local/bin/lndr
echo "done."

echo -n "Initializing zone registry ... "
mkdir -p ${LANDER_HOME}/zones
echo "done."

echo -n "Initalizing zone loader in .bashrc ... "
echo "" >> ~/.bashrc
echo "# LZ Loader" >> ~/.bashrc
echo "export LANDER_HOME=~/.lndr" >> ~/.bashrc
echo "source ${LANDER_HOME}/bin/bashrc-hook.sh" >> ~/.bashrc
echo "done."