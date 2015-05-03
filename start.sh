#!/bin/bash

BASEDIR=$(dirname $0)
ENV=development

if [[ $# > 0 ]]; then
    ENV=$1
fi

export NODE_ENV=$ENV

cd $BASEDIR/nodame
nodemon ./bin/www