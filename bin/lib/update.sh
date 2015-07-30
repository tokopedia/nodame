#!/bin/bash

BASEDIR=$(dirname $0)/../../../..
file=${BASEDIR}/configs/.build
timestamp=$(date +%s)
os=`uname -a`

cat << JSON > $file
{"time":${timestamp},"os":"${os}"}
JSON

echo ""
echo "Build data updated."
echo ""
