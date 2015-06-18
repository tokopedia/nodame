var express = require('express');
var async = require('async');
var path = nodame.import('path');
var httpRequest = nodame.import('http-request');
var jsonapi = nodame.import('jsonapi');

module.exports = (function () {
    var self = this;
    
    var hello = function (name) {
        return sprintf('Hello %s!', name);
    };

    return {
        hello: hello
    }
})();