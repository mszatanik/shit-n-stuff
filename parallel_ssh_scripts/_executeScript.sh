#!/bin/bash

# executes pssh and runs a script on each connection

while getopts s:h:p: option
do
	case "${option}"
	in
		s) SCRIPT_PATH=${OPTARG};;
		h) HOSTS_PATH=${OPTARG};;
		\?) echo
	esac
done

ERRORS=0
if [ -z SCRIPT_PATH ]; then
	ERRORS+=1
	echo "[!] please indicate what to run"
else
	if [ -f SCRIPT_PATH ]; then
		ERRORS+=1
		echo "[!] no such file $SCRIPT_PATH"
	fi
fi

if [ -z HOSTS_PATH ]; then
	ERRORS+=1
	echo "[!] please specify hosts file"
else
	if [ -f HOSTS_PATH ]; then
		ERRORS+=1
		echo "[!] no such file $HOSTS_PATH"
	fi
fi

if [ "$ERRORS" != "0" ]; then
	echo "[!] please correct errors"
	echo
	echo "[?] Usage: _executeScript.sh -s <script> -h <hosts file> [-p <script params>]"
	echo
	echo "\n  DESCRIPTION"
	echo "\t-s\t- script to execute on multiple machines"
	echo "\t-h\t- hosts file"
	echo "\t-h\t- params passed to script"
	echo
	echo
	exit 1
fi

echo "this script executes another script on multiple hosts in parallel, using parallel-ssh ..."
sleep 1
echo ", so it's just a wrapper"

echo "[>] parallel-ssh -A -h $HOSTS_PATH -P -I<$SCRIPT_PATH ..."
parallel-ssh -A -h $HOSTS_PATH -P -I<$SCRIPT_PATH


