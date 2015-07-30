#!/bin/bash

BASEDIR=$(dirname $0)/../..
ROOTDIR=$BASEDIR/../..
ROOT_LIST=(
    index.js
    .gitignore
    nodemon.json
    assets
    handlers
    services
    modules
    bootwares
    views
    configs
    middlewares
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

echo -e "${cyan}TASK: [Copy files] *****************${rep}${reset}"
count=0
for nodame_file in ${NODAME_LIST[@]}; do
    cp -rf ${BASEDIR}/${nodame_file} ${ROOTDIR}/
    count=$((count+1))
done
echo -e "${green}summary     : ok=$count  failed=0${reset}"
echo ""

echo -e "${cyan}TASK: [Update build data] **********${rep}${reset}"
$BASEDIR/bin/nodame -u
echo -e "${green}summary     : ok=1  failed=0${reset}"


echo -e "${cyan}Finished: SUCCESS${reset}"
echo ""
