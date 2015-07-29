#!/bin/bash
set -e
BASEDIR=$(dirname $0)/../..

src=$BASEDIR/src
bin=$BASEDIR/lib/bin
lib=$BASEDIR/lib/node_modules/nodame
tmp=$BASEDIR/tpl
tmp=$BASEDIR/.tmp
red="\033[0;31m"
green="\033[0;32m"
cyan="\033[0;36m"
yellow="\033[1;33m"
reset="\033[0m"
rep="*************************"

failed(){
    echo ""
    echo -e "${cyan}Finished: FAILED${reset}"
    echo -e "${red}Error: Failed to compile Nodame${reset}" &1>&2
    echo ""
    exit 1
}

echo ""
echo -e "${yellow}PLAY: [Compile Nodame] *************${rep}${reset}"
echo ""

echo -e "${cyan}TASK: [Clean target directory] *****${rep}${reset}"
libdirs=(
    $bin
    $lib
)
count=0
for libdir in ${libdirs[@]}; do
    files=(${libdir}/**/*)
    count=$((count+${#files[@]}))
done
rm -rf $BASEDIR/lib/bin
rm -rf $BASEDIR/lib/node_modules

echo -e "${green}>> $count files removed.${reset}"
echo ""

echo -e "${cyan}TASK: [Compile *.coffee files] *****${rep}${reset}"
mkdir -p $tmp || failed
files=($src/*.coffee)
count=0
for file in ${files[@]}; do
    coffee -o $tmp -c $file || failed
    count=$((count+1))
done
echo -e "${green}>> $count files compiled.${reset}"
echo ""

echo -e "${cyan}TASK: [Copy *.js files] ************${rep}${reset}"
srcjs=(
    $tmp
    $src
)
count=0
for js in ${srcjs[@]}; do
    files=(${js}/*.js)
    for file in ${files[@]}; do
        dirname=${file%.js}
        filename=index.js
        if [[ $file == .*_test.js ]]; then
            dirname=${file%_test.js}
            filename=test.js
        fi
        dirname=${dirname##*/}
        dstdir=$lib/${dirname}
        mkdir -p $dstdir || failed
        cp $file ${dstdir}/$filename || failed
        count=$((count+1))
    done
done
echo -e "${green}>> $count files copied.${reset}"
echo ""

echo -e "${cyan}TASK: [Clean up tmp files] *********${rep}${reset}"
files=($tmp/*.js)
rm -rf $tmp || failed
echo -e "${green}>> ${#files[@]} files removed.${reset}"
echo ""

echo -e "${cyan}TASK: [Copy config files] **********${rep}${reset}"
mkdir -p ${lib}/config || failed
cp ${src}/config.json ${lib}/config/ || failed
echo -e "${green}>> 1 files copied.${reset}"
echo ""

echo -e "${cyan}TASK: [Create executable files] ****${rep}${reset}"
mkdir -p ${bin} || failed
echo "#!/usr/bin/env node" > ${bin}/www
cat ${lib}/www/index.js >> ${bin}/www || failed
rm -rf ${lib}/www || failed
chmod +x ${bin}/www || failed
echo -e "${green}>> 1 files created.${reset}"
echo ""

echo -e "${cyan}Finished: SUCCESS${reset}"
echo ""
