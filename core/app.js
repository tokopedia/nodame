var express         = require('express');

var cookieParser    = require('cookie-parser');
var bodyParser      = require('body-parser');
var device          = require('express-device');
var methodOverride  = require('method-override');
var fs              = require('fs');

// Global variable
sprintf             = require('sprintf-js').sprintf;
vsprintf            = require('sprintf-js').vsprintf;
helper              = require(__dirname + '/helper.js');

// Private Modules 
var toml            = helper.load.util('toml-js');
var file            = helper.load.util('file');
var path            = helper.load.util('path');

// Environment constants 
var productionEnv   = ['production', 'staging'];
APP_ENV             = process.env.NODE_ENV !== undefined ? process.env.NODE_ENV : 'development';
IS_DEV              = productionEnv.indexOf(APP_ENV) < 0;

// Expressjs initialization
var app             = express();
app.env             = APP_ENV;
// Trust proxy setup
app.set('trust proxy', 'uniquelocal');
app.enable('trust proxy');

// Config
var configPath      = IS_DEV ? 'config-devel' : 'config';
var configDefault   = path.normalize(__dirname + '/../../../' + configPath + '/main.ini');
var configStream    = process.env.NODE_CONFIG ? path.normalize(process.env.NODE_CONFIG) : configDefault;
var config          = toml.parse(fs.readFileSync(configStream));

// Config constants
MAINTENANCE         = config.server.maintenance === true;
TEMPLATE            = config.app.template;
MOBILE_TEMPLATE     = config.app.mobile_template;
ENFORCE_MOBILE      = config.app.enforce_mobile;
API_PROTOCOL        = config.app.api_protocol;
APPNAME             = config.app.appname;
SYS_PATH            = path.normalize(__dirname + '/..');
APP_PATH            = path.normalize(SYS_PATH + '../..');
CONFIG_DIR_PATH     = configStream.replace(/\/[a-zA-Z0-9\-\.]+$/, '');

// Load and store assets config
var assetsFilename  = IS_DEV ? 'assets.ini' : '.assets';
var assetsStream    = path.normalize(sprintf('%s/%s', CONFIG_DIR_PATH, assetsFilename));
config.assets       = IS_DEV ? file.readGRUNT(assetsStream) : file.readJSON(assetsStream);

// Store config to app
app.set('config', config);
helper.config.set(config);



// X-Powered-By header
app.set('x-powered-by', config.server.enable_powered_by);

// Device capture
app.use(device.capture());

// Log setup
var logger        = require(__dirname + '/logger.js');
app.use(logger.error());
app.use(logger.access());

// Block favicon
app.use(function (req, res, next) {
    if (req.url === '/favicon.ico') {
        res.writeHead(200, {'Content-Type': 'image/x-icon'});
        res.end();
    } else {
        next();
    }
});

// Static server setup
if (config.server.assets.serve_static) {
    var assetsRoute = path.normalize(sprintf('/%s', config.server.assets.route));
    var assetsDir   = path.normalize(sprintf('%s/%s', SYS_PATH, config.server.assets.dir));

    app.use(assetsRoute, require('serve-static')(assetsDir));
}

// View engine setup
require('./views')(app);

// Redirect non-https on production
app.use(function (req, res, next) {
    if (!IS_DEV) {
        if (!req.secure) {
            res.redirect(config.server.url.hostname + req.originalUrl);
            next = false;
        }
    }

    if (next) return next();
});

// Middlewares Setups
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(methodOverride());

// Locals setup
require(__dirname + '/locals')(app);

// i18n setup
require(__dirname + '/i18n')(app);

// Numeral setup
require(__dirname + '/numeral')(app);

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
require(__dirname + '/routes')(app);

// Errors setup
require(__dirname + '/errors')(app);

module.exports = app;

