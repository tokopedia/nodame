var path    = require('path');
var redis   = require('redis');

function routes(app) {
    var appName       = nodame.config('app.appname');
    var defaultModule = nodame.config('app.default_module');
    var modules       = nodame.config('modules');
    var appRoute      = '/' + appName;
    //sesssion
    var session       = require('session');
    app.use(session.initSession);

    //set res.locals
    app.use(function (req, res, next) {
        //refback
        var refback;
        if (req.query.refback) {
            refback = req.query.refback;
            res.locals.refback = refback;
        }

        next();
    });

    var handlers = new Array();

    for (var module in modules) {
        var __config = modules[module];

        if (__config.enabled) {
            if (__config.dev_only && !IS_DEV) {
                continue;
            }

            var __handler = nodame.handler(module)
            var route = appRoute + '/';

            if (module != defaultModule) {
                route += module + '/';
            }

            if (__config.middleware) {
                var middleware = nodame.middleware(module);
                app.use(route, middleware.init);
            }

			var ajaxOnly = __config.ajax && __config.ajax_only ? true : false;

            if (!ajaxOnly) {
                app.use(route, __handler);
            }

            if (__config.ajax) {
                var ajaxRoute = appRoute + '/ajax/' + module + '/';
                app.use(ajaxRoute, __handler);
            }
        }
    }

    // Redirect '/' to 'home'
    if (nodame.config('app.root_redirect')) {
        app.use('/', function (req, res) {
            var hostname = nodame.config('server.url.hostname');
            var url = hostname + path.normalize('/' + appName);
            res.redirect(url);
        });
    }
}

module.exports = routes;
