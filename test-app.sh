#!/bin/bash
BASEDIR=$(dirname $0)/../..
set -e
red="\033[0;31m"
green="\033[0;32m"
cyan="\033[0;36m"
yellow="\033[1;33m"
reset="\033[0m"
rep="*************************"

$BASEDIR/bin/nodame -C || exit

echo ""
echo -e "${yellow}PLAY: [App Unit Test] **************${rep}${reset}"
echo -e "${green}powered by mocha${reset}"
echo ""

mocha -R "nyan" $BASEDIR/lib/**/test.js || exit
