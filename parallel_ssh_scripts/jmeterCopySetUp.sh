#!/bin/bash

# copy and execute script
# the aim is to copy jmeter to multiple hosts and set it up
# pscp is wrapped in "_copyFiles.sh"
# pssh is wrapped in "_executeScript.sh"

HOSTS_PATH="hosts.txt"

# each consecutive script checks params, so we check only the number of them passed to this script
if [ "$#" -ne 3 ]; then
	echo "[!] invalid number of params passed"
	exit 1
else
	COPY_WHAT="$1"
	COPY_WHERE="$2"
	echo "[>] bash_copyFiles.sh $HOSTS_PATH $COPY_WHAT $COPY_WHERE ..."
	eval bash _copyFiles.sh" $HOSTS_PATH $COPY_WHAT $COPY_WHERE"

	SCRIPT_PATH="$3"
	SCRIPT_PARAMS="$COPY_WHAT"
	echo "[>] bash _executeScript.sh -h $HOSTS_PATH -s $SCRIPT_PATH ..."
	
	parallel-ssh -A -h $HOSTS_PATH -P -I<$SCRIPT_PATH
fi
