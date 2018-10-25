#!/bin/bash

# https://nmap.org/book/man-briefoptions.html
# https://www.cyberciti.biz/security/nmap-command-examples-tutorials/
# https://latesthackingnews.com/2018/09/22/nmap-bootstrap-xsl-hack-creates-visually-appealing-nmap-scan-reports-interview-with-its-creator-andreas-hontzia/#
# https://github.com/vulnersCom/nmap-vulners
# https://github.com/scipag/vulscan
# https://github.com/honze-net/nmap-bootstrap-xsl
# http://www.cheat-sheets.org/#NMAP

# CHANGES ::
# -- added $2 for user defined options
# -- posibility to choose more than one option in second wizard's window
# -- posibility to pipe nmap output to nikto

# TODO ::
# -- "install scripts" option doesnt remove tmp
# -- multiple runs fucks up reports - so we can create scanme file in the correct folder straight away


trap ctrl_c INT
SCAN_PROFILE=""
IGNORE_HOST_DOWN=0
SCRIPT_PATH="/usr/share/nmap/scripts"
START_TIME=$(date "+%Y-%m-%d_%H-%M-%S")
COMMAND="nmap"

# ctrl+c hook
function ctrl_c() {
	echo "[?] CTRL-C trapped."
	exit 1
	end
}

# welcome message if invalid params are passed
function hello {
	echo
	echo -ne "Usage: nmap_wrapper.sh <host> <options>"
	echo
	echo -ne "\n  host\t- IP address or domain name of the host target."
	echo -ne "\n  options\t- any additional options like -p80,443."
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
OPTIONS="$2"

# check if host is up
ping -c 1 "$TARGET" 2>&1 > /dev/null

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
	echo -e "\t6. Ping sweep"
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

CVE_SCAN=0
MAKE_REPORT=0
NIKTO_PIPE=0
OPTIONS_DONE=0

while [ "$OPTIONS_DONE" == "0" ]; do
	echo "[>] Please select scan type:"
	#
	if [ "$CVE_SCAN" == "0" ]; then
		echo -e "\t[ ]\t1. Scan for CVE"
	else
		echo -e "\t[${RED}x${ENDC}]\t1. Scan for CVE"
	fi
	#
	if [ "$MAKE_REPORT" == "0" ]; then
		echo -e "\t[ ]\t2. Create a report"
	else
		echo -e "\t[${RED}x${ENDC}]\t2. Create a report"
	fi
	#
	if [ "$NIKTO_PIPE" == "0" ]; then
		echo -e "\t[ ]\t3. Pipe to NIKTO"
	else
		echo -e "\t[${RED}x${ENDC}]\t3. Pipe to NIKTO"
	fi
	#
	echo -e "\t\t0. Finish"
	
	read -p "Please select an option: " m
	
	if [ $m -eq 0 ]; then OPTIONS_DONE=1
	elif [ $m -eq 1 ]; then 
		if [ "$CVE_SCAN" == "0" ]; then
			CVE_SCAN=1
		else
			CVE_SCAN=0
		fi
	elif [ $m -eq 2 ]; then 
		if [ "$MAKE_REPORT" == "0" ]; then
			MAKE_REPORT=1
		else
			MAKE_REPORT=0
		fi
	elif [ $m -eq 3 ]; then 
		if [ "$NIKTO_PIPE" == "0" ]; then
			NIKTO_PIPE=1
		else
			NIKTO_PIPE=0
		fi
	else echo "[!] Unknown profile selected" && exit 1
	fi
	echo
done

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
if [ "$CVE_SCAN" == "1" ]; then
	COMMAND+=" --script vulners,vulscan --script-args vulscandb=scipvuldb.csv -A --reason"
fi
if [ "$MAKE_REPORT" == "1" ]; then
	COMMAND+=" -oA scanme --stylesheet $SCRIPT_PATH/nmap-bootstrap-xsl/nmap-bootstrap.xsl"
fi

if [ ! -z "$OPTIONS" ]; then
	COMMAND+=" $OPTIONS"
fi

COMMAND+=" $TARGET"

# HAS TO BE LAST
if [ "$NIKTO_PIPE" == "1" ]; then
	COMMAND+=" -oG - | nikto -h -"
fi

echo "[+] Tasked: '$SCAN_PROFILE' scan against '$TARGET' "
echo "[>] ..."

# execute
echo "[>] $COMMAND..."
eval $COMMAND

if [ -f "scanme.xml" ]; then
	xsltproc -o scanme.html $SCRIPT_PATH/nmap-bootstrap-xsl/nmap-bootstrap.xsl scanme.xml
	mkdir -p reports/$START_TIME
	mv scanme* reports/$START_TIME
fi
