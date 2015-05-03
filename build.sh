#!/bin/bash

BASEDIR=$(dirname $0)
ROOTDIR=$BASEDIR/..
ROOT_LIST=(
    node_modules
    bower_components
    .gitignore
)
NODAME_LIST=(
    start.sh
    package.json
    bower.json
    src
)

echo ""

echo "Preparing installation"
echo "------------------------------"
for root_file in ${ROOT_LIST[@]}; do
    echo -n "deleting $root_file/ ... "
    rm -rf $ROOTDIR/$root_file
    echo "done"
done
for nodame_file in ${NODAME_LIST[@]}; do
    echo -n "deleting $nodame_file ... "
    rm -rf $ROOTDIR/$nodame_file
    echo "done"
done
for nodame_file in ${NODAME_LIST[@]}; do
    echo -n "copying nodame/$nodame_file ... "
    cp -rf $BASEDIR/$nodame_file $ROOTDIR/
    echo "done"
done
echo -n "copying .gitignore ... "
mv $ROOTDIR/src/.gitignore $ROOTDIR/
echo "done"
echo ""

echo "Installing node modules"
echo "-----------------------"
npm install
echo ""

echo "Installing bower components"
echo "---------------------------"
bower install
echo ""

ASSETS_DIR=$ROOTDIR/src/assets

echo "Copying bower components"
echo "------------------------"
echo -n "copying bower_components to src/assets ... "
cp -rf $ROOTDIR/bower_components $ROOTDIR/src/assets/
echo "done"
echo -n "creating polymer dir in src/assets/js ... "
mkdir -p $ROOTDIR/src/assets/js/polymer
echo "done"
cp $ASSETS_DIR/bower_components/webcomponentsjs/*.min.js $ASSETS_DIR/js/polymer/
cp $ASSETS_DIR/bower_components/web-animations-js/*.min.js $ASSETS_DIR/js/polymer/
POLYMER_FILES=`ls $ASSETS_DIR/js/polymer`
for file in $POLYMER_FILES; do
    echo -n "moving $file to assets/js ... "
    mv $ASSETS_DIR/js/polymer/$file $ASSETS_DIR/js/polymer.$file
    echo "done"
done
echo ""

echo "Cleaning installation files"
echo "---------------------------"
echo -n "deleting bower_components ... "
rm -rf $ROOTDIR/bower_components
echo "done"
echo -n "deleting bower.json ... "
rm -rf $ROOTDIR/bower.json
echo "done"
echo -n "deleting src/assets/bower_components/webcomponentsjs ... "
rm -rf $ASSETS_DIR/bower_components/webcomponentsjs
echo "done"
echo -n "deleting src/assets/bower_components/web-animations-js ... "
rm -rf $ASSETS_DIR/bower_components/web-animations-js
echo "done"
echo -n "deleting src/assets/js/polymer ... "
rm -rf $ASSETS_DIR/js/polymer
echo "done"

echo ""
echo "nodame installation is done!"
echo ""
