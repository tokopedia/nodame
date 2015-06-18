var express = require('express');
var router = express.Router();
var async = require('async');
var validate = require("validate.js");

var path = nodame.import('path');
var utilHtml = nodame.import('html');

var service = nodame.service('home');

router.get('/', function (req, res, next) {
    var greets = service.hello('World!');

    var html = utilHtml.new(req, res);
    html.stash.set('greets', greets);
    html.render({
        module: 'home',
        file: 'index'
    })
});

module.exports = router;