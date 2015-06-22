#!/bin/bash

BASEDIR=$(dirname $0)
ASSETS_DIR=$BASEDIR/../../assets/min

echo ""
echo "Cleaning assets"
echo "---------------"

if [[ "$(ls -A $ASSETS_DIR)" ]]; then
    FILES=`ls $ASSETS_DIR`
    for file in $FILES; do
        echo -n "deleting $file ... "
        rm $ASSETS_DIR/$file
        echo "done"
    done
else
    echo "No assets found"
fi
echo ""

echo "Running grunt"
echo "-------------"
grunt --gruntfile ${BASEDIR}/Gruntfile.js
