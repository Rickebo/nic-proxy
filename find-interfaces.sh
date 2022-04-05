#!/bin/bash

usage() {
    echo "Usage: $0 [-f <1.1.1.1>] [-a <https://my.ip-api.com/>]" 1>&2;
    exit 1;
}

API=https://api.ipify.org/
EXCLUDE_CURRENT=0
CURL_TIMEOUT=5

while getopts ":f:a:d" o; do
    case "${o}" in
        f)
            BLACKLIST_INPUT=${OPTARG}
            ;;
        a)
            API=${OPTARG}
            ;;
        d)
            EXCLUDE_CURRENT=1
            ;;
        *)
            usage
            ;;
    esac
done

if [[ $EXCLUDE_CURRENT -eq 1 ]];
then
    CURRENT=$(curl --connect-timeout $CURL_TIMEOUT -s $API)
    BLACKLIST_INPUT="$BLACKLIST_INPUT,$CURRENT"
fi

IFS=', ' read -r -a BLACKLIST_IPS <<< "$BLACKLIST_INPUT"
INTERFACES=$(ip -o link show | awk -F': ' '{print $2}')
WORKING_EXIT_CODE=0

containsElement () {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

EXIT_CODE=1

while IFS= read -r interface; do
    IP=$(curl -s --connect-timeout $CURL_TIMEOUT --interface $interface $API)

    if [[ $? -eq $WORKING_EXIT_CODE ]];
    then
        if ! containsElement $IP ${BLACKLIST_IPS[@]}
        then
            EXIT_CODE=0
            echo "$interface: $IP"
        fi
    fi
done <<< "$INTERFACES"

exit $EXIT_CODE
