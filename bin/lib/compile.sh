#!/bin/bash
set -e
BASEDIR=$(dirname $0)/../..

src=$BASEDIR/src
bin=$BASEDIR/bin
lib=$BASEDIR/lib
TEST=$BASEDIR/test
TEMP=$BASEDIR/.tmp
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
files=($lib/*)
count=$((count+${#files[@]}))
rm -rf $lib
rm -f $bin/www
echo -e "${green}>> $count files removed.${reset}"
echo ""

echo -e "${cyan}TASK: [Compile *.coffee files] *****${rep}${reset}"
mkdir -p $TEMP || failed
files=($src/*.coffee)
count=0
for file in ${files[@]}; do
    coffee -o $TEMP -c $file || failed
    count=$((count+1))
done
echo -e "${green}>> $count files compiled.${reset}"
echo ""

echo -e "${cyan}TASK: [Copy *.js files] ************${rep}${reset}"
srcjs=(
    $TEMP
    $src
)
mkdir -p $lib
mkdir -p $TEST
count=0
for js in ${srcjs[@]}; do
    files=(${js}/*.js)
    for file in ${files[@]}; do
        destination=$lib
        if [[ $file == .*_test.js ]]; then
            destination=$TEST
        fi
        cp $file $destination/ || failed
        count=$((count+1))
    done
done
echo -e "${green}>> $count files copied.${reset}"
echo ""

echo -e "${cyan}TASK: [Clean up tmp files] *********${rep}${reset}"
files=($TEMP/*.js)
rm -rf $TEMP || failed
echo -e "${green}>> ${#files[@]} files removed.${reset}"
echo ""

echo -e "${cyan}TASK: [Copy config files] **********${rep}${reset}"
cp ${src}/config.json ${lib}/ || failed
echo -e "${green}>> 1 files copied.${reset}"
echo ""

echo -e "${cyan}TASK: [Create executable files] ****${rep}${reset}"
echo "#!/usr/bin/env node" > ${bin}/www
cat ${lib}/www.js >> ${bin}/www || failed
rm ${lib}/www.js || failed
chmod +x ${bin}/www || failed
echo -e "${green}>> 1 files created.${reset}"
echo ""

echo -e "${cyan}Finished: SUCCESS${reset}"
echo ""
