var router      = nodame.router();
var async       = nodame.require('async');
var validate    = nodame.require('nodame/validate');
var path        = nodame.require('path');
var utilHtml    = nodame.require('nodame/html');
var service     = nodame.require('service/home');

router.get('/', function (req, res, next) {
    var greets  = service.hello('World');
    var html    = utilHtml.new(req, res);

    html.stash.set('greets', greets);
    html.render({
        module: 'home',
        file: 'index'
    });
});

module.exports = router;
