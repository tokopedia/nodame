#!/bin/bash

BASEDIR=$(dirname $0)/../..
ROOTDIR=$BASEDIR/../..
ROOT_LIST=(
    .gitignore
    assets
    bin
    configs
    handlers
    hooks
    index.js
    middlewares
    modules
    nodemon.json
    services
    views
)
NODAME_LIST=(
    tpl/*
)
red="\033[0;31m"
green="\033[0;32m"
cyan="\033[0;36m"
yellow="\033[1;33m"
reset="\033[0m"
rep="*************************"

is_coffee=false

if [[ $# -eq 1 && "$1" -eq 1 ]]; then
    is_coffee=true
fi

echo ""
echo -e "${yellow}PLAY: [Build Application Base] *****${rep}${reset}"
echo ""

echo -e "${cyan}TASK: [Clean up directories] *******${rep}${reset}"
count=0
for root_file in ${ROOT_LIST[@]}; do
    rm -rf ${ROOTDIR}/${root_file}
    count=$((count+1))
done
for nodame_file in ${NODAME_LIST[@]}; do
    rm -rf ${ROOTDIR}/${nodame_file}
    count=$((count+1))
done
echo -e "${green}summary     : ok=$count  failed=0${reset}"
echo ""

echo -e "${cyan}TASK: [Copy template directory] ****${rep}${reset}"
cp -rf $BASEDIR/tpl/* $ROOTDIR/
echo -e "${green}summary     : ok=1  failed=0${reset}"
echo ""

echo -e "${cyan}TASK: [Copy exec file] *************${rep}${reset}"
chmod +x $ROOTDIR/bin/nodame
echo -e "${green}summary     : ok=1  failed=0${reset}"
echo ""

echo -e "${cyan}TASK: [Update build data] **********${rep}${reset}"
$ROOTDIR/bin/nodame -u
echo -e "${green}summary     : ok=1  failed=0${reset}"

echo -e "${cyan}Finished: SUCCESS${reset}"
echo ""

$ROOTDIR/bin/nodame -c

if $is_coffee; then
cat << GITIGNORE >> $ROOTDIR/.gitignore
/handlers
/hooks
/middlewares
/modules
/services

GITIGNORE
else
    rm -rf $ROOTDIR/src
fi
