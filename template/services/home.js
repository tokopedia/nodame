var express = require('express');
var async = require('async');
var path = require('path');
var httpRequest = require('http-request');
var jsonapi = require('jsonapi');

module.exports = (function () {
    var self = this;
    
    var hello = function (name) {
        return sprintf('Hello %s!', name);
    };

    return {
        hello: hello
    }
})();