#!/bin/bash

BASEDIR=$(dirname $0)
ROOTDIR=$BASEDIR/../..
ROOT_LIST=(
    index.js
    .gitignore
    assets
    handlers
    services
    modules
    views
    configs
    middlewares
)
NODAME_LIST=(
    template/*
)

echo ""

echo "TASK: Preparing installation"
echo "----------------------------"
for root_file in ${ROOT_LIST[@]}; do
    echo -n "deleting ${ROOTDIR}/${root_file}/ ... "
    rm -rf ${ROOTDIR}/${root_file}
    echo "done"
done
for nodame_file in ${NODAME_LIST[@]}; do
    echo -n "deleting $nodame_file ... "
    rm -rf ${ROOTDIR}/${nodame_file}
    echo "done"
done
for nodame_file in ${NODAME_LIST[@]}; do
    echo -n "copying nodame/${nodame_file} ... "
    cp -rf ${BASEDIR}/${nodame_file} ${ROOTDIR}/
    echo "done"
done

echo ""
echo "nodame installation is done!"
echo ""
