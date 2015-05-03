var express = require('express');
var async = require('async');
var path = helper.load.util('path');
var httpRequest = helper.load.util('http-request');
var jsonapi = helper.load.util('jsonapi');

module.exports = (function () {
    var self = this;
    
    var hello = function (name) {
        return sprintf('Hello %s!', name);
    };

    return {
        hello: hello
    }
})();