#!/bin/bash

lib=$(dirname $0)
BASEDIR=$lib/../../../..
src=$BASEDIR/src
dst=$BASEDIR
tmp=$dst/.tmp
modules=(
    handlers
    hooks
    middlewares
    modules
    services
)
red="\033[0;31m"
green="\033[0;32m"
cyan="\033[0;36m"
yellow="\033[1;33m"
reset="\033[0m"
rep="*************************"
echo ""
echo -e "${yellow}PLAY: [Compile Application] ********${rep}${reset}"
echo ""

echo -e "${cyan}TASK: [Clean target directory] *****${rep}${reset}"
count=0
for module in ${modules[@]}; do
    rm -rf ${dst}/${module}
    count=$((count+1))
done
echo -e "${green}>> $count directories removed.${reset}"
echo ""

echo -e "${cyan}TASK: [Compile *.coffee files] *****${rep}${reset}"
mkdir -p $tmp
count=0
for module in ${modules[@]}; do
    files=(${src}/${module}/*.coffee)
    tmpout=$tmp/$module
    mkdir -p $tmpout
    if [ "${files[0]:(-8)}" != "*.coffee" ]; then
        for file in ${files[@]}; do
            coffee -o $tmpout -c $file
            count=$((count+1))
        done
    fi
done
echo -e "${green}>> $count files compiled.${reset}"
echo ""

echo -e "${cyan}TASK: [Copy compiled files] ********${rep}${reset}"
# Copy from sources
for module in ${modules[@]}; do
    files=($src/$module/*.js)
    cp $src/$module/*.js $tmp/$module/ &> /dev/null
done
# Copy from .tmp
count=0
for module in ${modules[@]}; do
    files=($tmp/$module/*.js)
    for file in ${files[@]}; do
        filename=${file##*/}
        dstdir=$dst/$module
        mkdir -p $dstdir
        dstfile=$dstdir/$filename
        cp $file $dstfile
        count=$((count+1))
    done
done
echo -e "${green}>> $count files copied.${reset}"
echo ""

echo -e "${cyan}TASK: [Clean temporary files] ******${rep}${reset}"
count=0
for module in ${modules[@]}; do
    files=($tmp/$module/*.js)
    count=$((count+${#files[@]}))
done
rm -rf $tmp
echo -e "${green}>> $count files removed.${reset}"
echo ""

echo -e "${cyan}TASK: [Update build] ***************${rep}${reset}"
$lib/update.sh &> /dev/null
echo -e "${green}>> build file updated."
echo ""

echo -e "${cyan}Finished: SUCCESS${reset}"
echo ""
