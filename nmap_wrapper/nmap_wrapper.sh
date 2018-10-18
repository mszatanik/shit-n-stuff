#!/bin/bash

# https://nmap.org/book/man-briefoptions.html
# https://www.cyberciti.biz/security/nmap-command-examples-tutorials/
# https://latesthackingnews.com/2018/09/22/nmap-bootstrap-xsl-hack-creates-visually-appealing-nmap-scan-reports-interview-with-its-creator-andreas-hontzia/#
# https://github.com/vulnersCom/nmap-vulners
# https://github.com/scipag/vulscan
# https://github.com/honze-net/nmap-bootstrap-xsl
# http://www.cheat-sheets.org/#NMAP

trap ctrl_c INT
SCAN_PROFILE=""
OPTIONS_PROFILE=""
IGNORE_HOST_DOWN=0
SCRIPT_PATH="/usr/share/nmap/scripts"
START_TIME=$(date "+%Y-%m-%d_%H-%M-%S")

# ctrl+c hook
function ctrl_c() {
	echo "[?] CTRL-C trapped."
	exit 1
	end
}

# welcome message if invalid params are passed
function hello {
	echo
	echo -ne "Usage: nmap_wrapper.sh <host>"
	echo
	echo -ne "\n  host\t- IP address or domain name of the host target."
	echo
	echo
}

# welcome message
RED='\033[0;31m'
ENDC='\033[0m'
echo ""
echo ""
echo "             ,%.            .%@@@@@@@@@@@@@@@@@@@@@@@@@@@/           .%.       "
echo "              *@@@%      .@@@@@@@@@&*.           ,#@@@@@@@@@/    .%@@@,        "
echo "               .@@@@@@@&@@@@@@#                        *@@@@@@@@@@@@@,         "
echo "                .@@@@@@@@@@@                             *@@@@@@@@@@.          "
echo "                  @@@@@@@@@@@@&                       #@@@@@@@@@@@@,           "
echo "                  ,@@@@@@@@@@@*                       .@@@@@@@@@@@@*           "
echo "                  @@@@@@@@@@@#                         /@@@@@@@@@@@@,          "
echo "                 &@@@@@@@@@#                             /@@@@@@%@@@@.         "
echo "                (@@@@,@&*                                   ,&@. @@@@@         "
echo "                @@@@&                                            /@@@@         "
echo "                @@@@/                                             @@@@*        "
echo "               .@@@@.                                             @@@@#        "
echo -e "               ,@@@@.       ${RED}&,                           (*${ENDC}       @@@@%        "
echo -e "               .@@@@.       ${RED}@@@@#                    *@@@@*${ENDC}       @@@@(        "
echo -e "                @@@@(          ${RED}.@@@@,             %@@@&${ENDC}          .@@@@,        "
echo -e "                @@@@@         ${RED}.@@@@@@% .       . &@@@@@@${ENDC}         #@@@@         "
echo -e "                ,@@@@,        ${RED}.@@@@@@#           &@@@@@@${ENDC}         @@@@%         "
echo -e "                 (@@@@.         ${RED}*&&(              .%&%,${ENDC}         #@@@@          "
echo "                  @@@@@                                        #@@@@,          "
echo "                  .@@@@&                                      (@@@@(           "
echo "                   ,@@@@@                                    &@@@@/            "
echo "                     @@@@@/                                 @@@@@*             "
echo "                      (@@@@@.     *@@@@@@@@@@@@@@@@&      @@@@@@.              "
echo "                        %@@@@@%                        /@@@@@@.                "

echo
echo "                                nmap automation script.                        "
echo "                                      mszatanik                                "
echo ""
echo

# if first param doesnt exist show hello() message and exit
# otherwise set TARGET to the param passed
if [ -z "$1" ]; then
	hello
	exit 1
fi
TARGET="$1"

# check if host is up
host "$TARGET" 2>&1 > /dev/null

# if not ask user to continue, and set -Pn flag to the command by setting IGNORE_HOST_DOWN variable
if [ $? -ne 0 ]; then
	echo "[!] Specified target host seems to be unavailable!"
	read -p "Are you sure you want to continue [Y/n]? It will set -Pn flag to ignore checking if the host is up " -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
		echo > /dev/null
		IGNORE_HOST_DOWN=1
	else
		exit 1
	fi
fi

# wizard letting you choose one of the options and setting SCAN_PROFILE variable based on the option
if [ -z "$SCAN_PROFILE" ]; then
	echo "[>] Please select scan type:"
	#
	echo -e "\t1. Regular scan"
	echo -e "\t\tNo params, no options, just a ... regular scan"
	#
	echo -e "\t2. Quick scan"
	echo -e "\t\t-T4\t\tIntensity Level 4"
	echo -e "\t\t-F\t\tFast Scan Mode"
	#
	echo -e "\t3. Intense scan"
	echo -e "\t\t-T4\t\tIntensity Level 4"
	echo -e "\t\t-A\t\tAdditional, Advanced, and Agressive"
	echo -e "\t\t-v\t\tVerbose Mode"
	#
	echo -e "\t4. Intense with UDP"
	echo -e "\t\t-sS\t\tTCP SYN Scan"
	echo -e "\t\t-sU\t\tUDP Scan"
	echo -e "\t\t-T4\t\tIntensity Level 4"
	echo -e "\t\t-A\t\tAdditional, Advanced, and Agressive"
	echo -e "\t\t-v\t\tVerbose Mode"
	#
	echo -e "\t5. Slow comprehensive scan"
	echo -e "\t\t-sS\t\tTCP SYN Scan"
	echo -e "\t\t-sU\t\tUDP Scan"
	echo -e "\t\t-T4\t\tIntensity Level 4"
	echo -e "\t\t-A\t\tAdditional, Advanced, and Agressive"
	echo -e "\t\t-v\t\tVerbose Mode"
	echo -e "\t\t-PE\t\tICMP Echo Request Ping"
	echo -e "\t\t-PP\t\tICMP Timestamp Ping"
	echo -e "\t\t-PS80,443\tTCP SYN Ping port 80, 443 (HTTP, HTTPS)"
	echo -e "\t\t-PA3389\t\tTCP ACK Ping port 3389 (RDP)"
	echo -e "\t\t-PU40125\tUDP Ping port 40125 for return ICMP (Default value)"
	echo -e "\t\t-PY\t\tSCTP INIT Ping"
	echo -e "\t\t-g 53\t\tsource-port"
	echo -e "\t\t--script 'default or (discovery and safe)'"
	#
	echo -e "\t6. Ping scan"
	echo -e "\t\t-sn\t\tPing Scan - disable port scan"
	#
	echo -e "\t9. Install scripts"
	echo -e "\t\trequires:\tsudo"
	echo -e "\t\trequires:\tgit"
	echo -e "\t\tinstalls to /usr/share/nmap/scripts"
	#
	echo -e "\t0. Exit"
	echo ""
	echo "--------------------------------"

	read -p "Please select an option: " m

	if [ $m -eq 0 ]; then exit 0;
	elif [ $m -eq 1 ]; then SCAN_PROFILE="Regular scan"
	elif [ $m -eq 2 ]; then SCAN_PROFILE="Quick scan"
	elif [ $m -eq 3 ]; then SCAN_PROFILE="Intense scan"
	elif [ $m -eq 4 ]; then SCAN_PROFILE="Intense with UDP"
	elif [ $m -eq 5 ]; then SCAN_PROFILE="Slow comprehensive scan"
	elif [ $m -eq 6 ]; then SCAN_PROFILE="Ping scan"
	elif [ $m -eq 9 ]; then SCAN_PROFILE="Install scripts"
	else echo "[!] Unknown profile selected" && exit 1
	fi
	echo
fi

if [ ! -z "$SCAN_PROFILE" ]; then
	if [ -z "$OPTIONS_PROFILE" ]; then
		echo "[>] Please select scan type:"
		#
		echo -e "\t1. Scan for CVE"
		#
		echo -e "\t2. Create a report"
		#
		echo -e "\t3. Scan for CVE and Create a report"
		
		read -p "Please select an option: " m
		
		if [ $m -eq 0 ]; then exit 0;
		elif [ $m -eq 1 ]; then OPTIONS_PROFILE="Scan for CVE"
		elif [ $m -eq 2 ]; then OPTIONS_PROFILE="Create a report"
		elif [ $m -eq 3 ]; then OPTIONS_PROFILE="Scan for CVE and Create a report"
		else echo "[!] Unknown profile selected" && exit 1
		fi
		echo
	fi
fi

COMMAND="nmap"
# run the COMMAND based on option
if [ "$SCAN_PROFILE" == "Regular scan" ]; then
	COMMAND+=""
elif [ "$SCAN_PROFILE" == "Quick scan" ]; then
	COMMAND+=" -T4 -F"
elif [ "$SCAN_PROFILE" == "Intense scan" ]; then
	COMMAND+=" -T4 -A -v"
elif [ "$SCAN_PROFILE" == "Intense with UDP" ]; then
	COMMAND+=" -sS -sU -T4 -A -v"
elif [ "$SCAN_PROFILE" == "Slow comprehensive scan" ]; then
	COMMAND+=" -sS -sU -T4 -A -v -PE -PP -PS80,443 -PA3389 -PU40125 -PY -g 53 --script 'default or (discovery and safe)'"
elif [ "$SCAN_PROFILE" == "Ping scan" ]; then
	COMMAND+=" -sn"
elif [ "$SCAN_PROFILE" == "Install scripts" ]; then
	echo "[>] ..."
	mkdir -p tmp/nmap/scripts
	cd tmp/nmap/scripts
	git clone "https://github.com/scipag/vulscan.git"
	git clone "https://github.com/vulnersCom/nmap-vulners.git"
	git clone "https://github.com/honze-net/nmap-bootstrap-xsl.git"
	
	cp -R vulscan $SCRIPT_PATH
	cp nmap-vulners/vulners.nse $SCRIPT_PATH
	cp -R nmap-bootstrap-xsl $SCRIPT_PATH
	
	rm -rf tmp
fi

# COMMAND alteration based on variables
if [ "$IGNORE_HOST_DOWN" == "1" ]; then
	COMMAND+=" -Pn"
fi
if [ "$OPTIONS_PROFILE" == "Scan for CVE" ]; then
	COMMAND+=" --script vulners,vulscan --script-args vulscandb=scipvuldb.csv -A --reason"
fi
if [ "$OPTIONS_PROFILE" == "Create a report" ]; then
	COMMAND+=" -oA scanme --stylesheet $SCRIPT_PATH/nmap-bootstrap-xsl/nmap-bootstrap.xsl"
fi
if [ "$OPTIONS_PROFILE" == "Scan for CVE and Create a report" ]; then
	COMMAND+=" --script vulners,vulscan --script-args vulscandb=scipvuldb.csv -A --reason -oA scanme --stylesheet $SCRIPT_PATH/nmap-bootstrap-xsl/nmap-bootstrap.xsl"
fi

COMMAND+=" $TARGET"

echo "[+] Tasked: '$SCAN_PROFILE' scan against '$TARGET' "
if [ ! -z "$OPTIONS_PROFILE" ]; then
	echo "[+] In addition: '$OPTIONS_PROFILE'"
fi
echo "[>] ..."

# execute
echo "[>] $COMMAND..."
$COMMAND

if [ -f "scanme.xml" ]; then
	xsltproc -o scanme.html $SCRIPT_PATH/nmap-bootstrap-xsl/nmap-bootstrap.xsl scanme.xml
	mkdir -p reports/$START_TIME
	mv scanme* reports/$START_TIME
fi
