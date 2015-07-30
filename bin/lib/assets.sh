#!/bin/bash

BASEDIR=$(dirname $0)/../..
dir=$BASEDIR/../../assets/min

red="\033[0;31m"
green="\033[0;32m"
cyan="\033[0;36m"
yellow="\033[1;33m"
reset="\033[0m"
rep="*************************"

echo ""
echo -e "${yellow}PLAY: [Build Assets] ***************${rep}${reset}"
echo ""

echo -e "${cyan}TASK: [Clean up assets] ************${rep}${reset}"
count=0
mkdir -p $dir
if [[ "$(ls -A $dir)" ]]; then
    FILES=`ls $dir`
    for file in $FILES; do
        rm $dir/$file
        count=$((count+1))
    done
fi
echo -e "${green}>> $count files removed.${reset}"
echo ""

echo -e "${cyan}TASK: [Run grunt] ******************${rep}${reset}"
grunt --gruntfile ${BASEDIR}/Gruntfile.js

echo ""
echo -e "${cyan}Finished: SUCCESS${reset}"
echo ""
