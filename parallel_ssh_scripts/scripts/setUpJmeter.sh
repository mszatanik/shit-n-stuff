#!/bin/bash

# unpack
# change permissions if needed

FILE_ARCHIVE="file_to_transfer.tar.gz"
FOLDER_NAME="$2"


if [ ! -z "$FILE_ARCHIVE" ]; then
	IFS='.' read -r -a tmp <<< "$FILE_ARCHIVE"
	COMPRESSION=${tmp[${#tmp[@]}-1]}

	if [ -z "$FOLDER_NAME" ]; then
		FOLDER_NAME=${tmp[0]}
		echo "[?!] Assuming the uncompressed folder is named like the archive ..."
	fi

	# Extracting
	echo "[>] extracting: $FILE_ARCHIVE to $FOLDER_NAME"

	case "${COMPRESSION}"
	in
		zip) unzip "$FILE_ARCHIVE";;
		tar) tar -xf "$FILE_ARCHIVE";;
		gz) tar -xzf "$FILE_ARCHIVE";;
	esac

	if [ -d "$FOLDER_NAME" ]; then
		# check permissions
		echo "[>] extracted ..."
		echo "[>] checking permissions ..."
		JMETER_EXECUTABLE="$FOLDER_NAME/bin/jmeter"
		if [ -f "$JMETER_EXECUTABLE" ]; then
			if [ ! -x "$JMETER_EXECUTABLE" ]; then
				chmod +x "$JMETER_EXECUTABLE"
				echo "[>] adding +x to $JMETER_EXECUTABLE ..."
			else
				echo "[>] permissions ok ..."
			fi
		else
			echo "[!] no executable found !"
			exit 1
		fi
		echo "[>] all ok."
	else
		echo "[!] $FOLDER_NAME not found ..."
		exit 1
	fi
else
	echo "[!] -f param not passed ..."
	exit 1
fi
