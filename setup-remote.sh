#!/bin/bash
REPO_NAME=nic-proxy
REPO=https://github.com/Rickebo/$REPO_NAME.git
STARTUP_SCRIPT=setup-danted.sh

REQUIRED_COMMANDS=(sudo git curl iproute2)

for required in ${REQUIRED_COMMANDS[@]}; do
    if ! command -v $required &> /dev/null;
    then
        echo "Installing $required..."
        apt install $required -y
    fi
done

TMP=$(mktemp -d)

git clone $REPO $TMP

if [ "$EUID" -ne 0 ]
then
    sudo chmod -R +x $TMP
    sudo $TMP/$STARTUP_SCRIPT
    sudo rm -r $TMP
else
    chmod -R +x $TMP
    $TMP/$STARTUP_SCRIPT
    rm -r $TMP
fi
