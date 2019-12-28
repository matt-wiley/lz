#!/usr/bin/env bash

echo ""
echo "Ensuring dependecies are installed you may be prompted for your password ... "
requirements="curl unzip"
toInstall=""
for req in ${requirements}; do
    if [[ -z "$(which ${req})" ]]; then
        toInstall="${toInstall} ${req}"
    fi
done

if [[ -n "${toInstall}" ]]; then
    echo "Attempting to install: ${toInstall}"
    sudo apt-get install -y ${toInstall}
fi
echo ""
echo "Dependencies ready."

echo ""
echo -n "Downloading LZ archive ... "
curl -sL https://github.com/wileymab/landing-zone/blob/master/downloads/lz.zip?raw=true -o lz.zip
echo "done."

echo ""
echo -n "Unpacking LZ files ... "
unzip -qq -o lz.zip -d ~
export LANDER_HOME=~/.lndr
rm -rf lz.zip
echo "done."

echo ""
echo -n "Installing executable ... "
ln -sf ~/.lndr/bin/lndr.sh /usr/local/bin/lndr
echo "done."

echo ""
echo -n "Initializing zone registry ... "
mkdir -p ${LANDER_HOME}/zones || true
echo "done."

echo ""
echo -n "Initalizing zone loader in .bashrc ... "
echo "" >> ~/.bashrc
echo "# LZ Loader" >> ~/.bashrc
echo "export LANDER_HOME=~/.lndr" >> ~/.bashrc
echo "source ${LANDER_HOME}/bin/bashrc-hook.sh" >> ~/.bashrc
echo "done."