var path    = helper.load.util('path');
var redis   = require("redis");

function routes(app) {
    var appName       = helper.config.get('app.appname');
    var defaultModule = helper.config.get('app.default_module');
    var modules       = helper.config.get('modules');
    var appRoute      = '/' + appName;
    //sesssion
    var session       = helper.load.util('session');
    app.use(session.initSession);

    //set res.locals
    app.use(function (req, res, next) {        
        //refback
        var refback;
        if(req.query.refback) {
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

            var __handler = helper.load.handler(module)
            var route = appRoute + '/';

            if (module != defaultModule) {
                route += module + '/';
            }

            if (__config.middleware) {
                var middleware = require(path.normalize(__dirname + '/../src/middlewares/' + module));
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
    if (helper.config.get('app.root_redirect')) {
        app.use('/', function (req, res) {
            var hostname = helper.config.get('server.url.hostname');
            var url = hostname + path.normalize('/' + appName);
            res.redirect(url);
        });
    }
}

module.exports = routes;
