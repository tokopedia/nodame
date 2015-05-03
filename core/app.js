SYS_PATH            = __dirname + '/..';
APP_PATH            = SYS_PATH + '/../src';
var express         = require('express');

var cookieParser    = require('cookie-parser');
var bodyParser      = require('body-parser');
var device          = require('express-device');
var methodOverride  = require('method-override');
var fs              = require('fs');

// Global variable
sprintf             = require('sprintf-js').sprintf;
vsprintf            = require('sprintf-js').vsprintf;
helper              = require('./helper.js');

// Private Modules 
var toml            = helper.load.util('toml-js');
var path            = helper.load.util('path');

// Environment constants 
APP_ENV             = process.env.NODE_ENV !== undefined ? process.env.NODE_ENV : 'development';
IS_DEV              = APP_ENV !== 'production' && APP_ENV !== 'staging';

var file            = helper.load.util('file')(APP_ENV);

// Expressjs initialization
var app             = express();
app.env             = APP_ENV;
// Trust proxy setup
app.set('trust proxy', 'uniquelocal');
app.enable('trust proxy');

// Config
var configPath      = IS_DEV ? 'config-devel' : 'config';
var configStream    = path.normalize(APP_PATH + '/' + configPath + '/main.ini');
var config          = toml.parse(fs.readFileSync(configStream));

// Config constants
MAINTENANCE         = config.server.maintenance === true;
TEMPLATE            = config.app.template;
MOBILE_TEMPLATE     = config.app.mobile_template;
ENFORCE_MOBILE      = config.app.enforce_mobile;
API_PROTOCOL        = config.app.api_protocol;
APPNAME             = config.app.appname;

// Load and store assets config
var assetsStream    = IS_DEV ? path.normalize(APP_PATH + '/config/assets.ini') : path.normalize(APP_PATH + '/config/.assets');
config.assets       = IS_DEV ? file.readGRUNT(assetsStream) : file.readJSON(assetsStream);

// Store config to app
config.streams      = {config: configStream, assets: assetsStream};
app.set('config', config);
helper.config.set(config);



// X-Powered-By header
app.set('x-powered-by', config.server.enable_powered_by);

// Log setup
var logger        = require('./logger.js');
app.use(logger.error());
app.use(logger.access());

// View engine setup
require('./views')(app);

// Redirect non-https on production
if (config.server.enforce_secure_connection) {
    app.use(function (req, res, next) {
        if (!IS_DEV) {
            if (!req.secure) {
                res.redirect(config.server.url.hostname + req.originalUrl);
                next = false;
            }
        }

        if (next) return next();
    });
}

// Middlewares Setups
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(methodOverride());
app.use(device.capture());

// Favicon setup
if (config.server.assets.serve_favicon) {
    var faviconPath = path.normalize(sprintf('%s/%s/%s', APP_PATH, config.server.assets.dir, config.server.assets.favicon));
    app.use(require('serve-favicon')(faviconPath));
}

// Static server setup
if (config.server.assets.serve_static) {
    var assetsRoute = path.normalize(sprintf('/%s', config.server.assets.route));
    var assetsDir   = path.normalize(sprintf('%s/%s', APP_PATH, config.server.assets.dir));

    app.use(assetsRoute, require('serve-static')(assetsDir));
}

// Locals setup
require('./locals')(app);

// i18n setup
require('./i18n')(app);

// Numeral setup
require('./numeral')(app);

// Enforce mobile setup
app.use(helper.enforceMobile());

// Locals helper setup
app.use(helper.locals(app));

app.use(function (req, res, next) {
    res.locals.path = new Object();
    var fullpath = req.originalUrl;
    res.locals.path['full'] = fullpath;
    res.locals.path['module'] = fullpath.replace('/' + APPNAME, '');

    if (next) return next();
});

app.use(function (req, res, next) {
    if (MAINTENANCE) {
        html = helper.load.util('html').new(req, res);
        html.headTitle('Tokopedia');
        html.headDescription('tokopedia');
        res.status(503);
        html.render({
            module: 'errors',
            file: '503'
        });
    }

    if (next && !MAINTENANCE) return next();
});

// Routes setup
require('./routes')(app);

// Errors setup
require('./errors')(app);

module.exports = app;

