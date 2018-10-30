#!/bin/bash

# this only copies files using pscp

echo "this script copies a file to multiple hosts using pscp ..."
sleep 1
echo ", so it's just a wrapper"

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
	echo "[!] not all params passed"
	exit 1
else
	HOSTS_PATH="$1"
	LOCAL="$2"
	REMOTE="$3"
	echo "[>] starting ..."
	echo "parallel-scp -h $HOSTS_PATH $LOCAL $REMOTE"
	eval parallel-scp -A -h" $HOSTS_PATH $LOCAL $REMOTE"
	echo "[>] all done"
	exit 0
fi
