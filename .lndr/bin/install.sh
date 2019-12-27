#!/usr/bin/env bash

# curl down the zip of the ./bin dir
# unzip it at ~/.lndr
#link ~/.lndr/bin/lndr.sh /usr/local/bin/lndr
# set LANDER_HOME=~/.lndr

echo -n "Initializing zone registry ... "
sleep 1 #remove
mkdir -p ${LANDER_HOME}/zones
echo "done."
sleep 1 #remove


echo -n "Adding zone loader to .bashrc ... "
sleep 1 #remove
echo "" >> ~/.bashrc
echo "# LZ Loader" >> ~/.bashrc
echo "source ${LANDER_HOME}/bin/bashrc-hook.sh" >> ~/.bashrc
echo "done."