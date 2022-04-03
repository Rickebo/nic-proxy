#!/bin/bash
HERE=$(dirname "$0")

TEMPLATE=dante-config.conf
TEMP=dante-config.conf.temp
TARGET=/etc/danted.conf

if [ "$EUID" -ne 0 ]
then
    me="$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")"
    echo "This script must be run as root."
    echo "Try this instead: sudo $me $@"
    exit
fi

echo "Looking for an appropriate network interface..."
INTERFACE_OUTPUT=$($HERE/find-interfaces.sh -d)

if [[ $? -ne 0 ]];
then
    echo "Could not find any non-default network interface. Is an additional network interface connected and usable?"
    exit 1
fi

ARRAY=($(sed 's/: / /g' <<< $INTERFACE_OUTPUT))
INTERFACE=${ARRAY[0]}
IP=${ARRAY[1]}
echo "Using interface: $INTERFACE, with apparent public IP $IP."

if ! command -v danted &> /dev/null
then
    "It appears like dante is not installed. It will therefore be installed now."
    (apt update && apt install -y dante-server) || exit 1
fi

echo "Setting up temporary danted.conf..."

rm $TEMP 2> /dev/null
cp $TEMPLATE $TEMP

sed -i "s/external:.*/external: $INTERFACE/g" $TEMP
mv -f $TEMP $TARGET

service danted restart

service danted status | grep 'not running' &> /dev/null

if [[ $? -eq 0 ]];
then
    echo "ERROR: danted is not running."
    exit 1
else
    echo "danted appears to be running."
    echo "Use the proxy by connecting to localhost (or 127.0.0.1), using port 1080."

    if [[ ! -z "$SUDO_USER" ]];
    then
        echo "Authenticate with your computers username ($SUDO_USER) and your password when using the proxy."
    else
        echo "Authenticate with your computers username and password."
    fi
fi



