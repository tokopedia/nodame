var argv            = require('commander');

// Set argv options
argv
    .usage('[options] <file ...>')
    .option('-c, --config <file>', 'Config file location')
    .option('-e, --env <env>', 'Application environment')
    .option('-s, --staging', 'Set staging environment')
    .option('-p, --production', 'Set production environment')
    .parse(process.argv);

// Set environment to be excluded as Development
var productionEnv   = ['production', 'staging'];
// Set default environment
APP_ENV             = 'development';

if (argv.staging || argv.production) {
    // Set priority in case all were called.
    // Staging > Production
    if (argv.production) {
        APP_ENV = 'production';
    }
    
    if (argv.staging) {
        APP_ENV = 'staging';
    }
} else {
    // Set priority in case both exist
    // argv.env > process.env.NODE_ENV
    if (process.env.NODE_ENV !== undefined) {
        APP_ENV = process.env.NODE_ENV;
    }
    
    if (argv.env !== undefined) {
        APP_ENV = argv.env;
    }
}

IS_DEV              = productionEnv.indexOf(APP_ENV) < 0;

express         = require('express');
var cookieParser    = require('cookie-parser');
var bodyParser      = require('body-parser');
var device          = require('express-device');
var methodOverride  = require('method-override');
var fs              = require('fs');

// Global variable
sprintf             = require('sprintf-js').sprintf;
vsprintf            = require('sprintf-js').vsprintf;
nodame              = require(__dirname + '/nodame.js');

// Private Modules 
var toml            = nodame.require('toml-js');
var file            = nodame.require('file');
var path            = nodame.require('path');

// Expressjs initialization
var app             = express();
app.env             = APP_ENV;
SYS_PATH            = path.normalize(__dirname + '/..');
APP_PATH            = path.normalize(SYS_PATH + '/../..');

// Trust proxy setup
app.set('trust proxy', 'uniquelocal');
app.enable('trust proxy');

// Config
var configStream;

if (argv.config !== undefined) {
    if (argv.config.substring(0,1) !== '/') {
        configStream = path.normalize(sprintf('%s/%s', APP_PATH, argv.config));
    } else {
        configPath = path.normalize(argv.config);   
    }
} else {
    var configDir = IS_DEV ? 'config-devel' : 'config';    
    configStream  = path.normalize(sprintf('%s/%s/main.ini', APP_PATH, configDir));
}

var config          = toml.parse(fs.readFileSync(configStream));

// Config constants
MAINTENANCE         = config.server.maintenance === true;
TEMPLATE            = config.app.template;
MOBILE_TEMPLATE     = config.app.mobile_template;
ENFORCE_MOBILE      = config.app.enforce_mobile;
API_PROTOCOL        = config.app.api_protocol;
APPNAME             = config.app.appname;
CONFIG_DIR_PATH     = configStream.replace(/\/[a-zA-Z0-9\-\.]+$/, '');

// Load and store assets config
var assetsFilename  = IS_DEV ? 'assets.ini' : '.assets';
var assetsStream    = path.normalize(sprintf('%s/config/%s', APP_PATH, assetsFilename));
config.assets       = IS_DEV ? file.readGRUNT(assetsStream) : file.readJSON(assetsStream);

// Store config to app
app.set('config', config);
nodame.config.set(config);



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
app.use(nodame.enforceMobile());

// Locals helper setup
app.use(nodame.locals(app));

app.use(function (req, res, next) {
    res.locals.path = new Object();
    var fullpath = req.originalUrl;
    res.locals.path['full'] = fullpath;
    res.locals.path['module'] = fullpath.replace('/' + APPNAME, '');

    if (next) return next();
});

app.use(function (req, res, next) {
    if (MAINTENANCE) {
        html = nodame.require('html').new(req, res);
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

