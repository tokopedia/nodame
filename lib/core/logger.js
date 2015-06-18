var logger = (function () {
    var self = this;

    if (IS_DEV) {
        var colors          = require('colors');
    }

    var client              = nodame.config('logger.client');

    switch (client) {
        case 'sentry':
            var raven        = require('raven');
            var sentryClient = new raven.Client(nodame.config('logger.sentry_dns'));
            break;

        default:
            var fs           = require('fs');
            var path         = nodame.import('path');        
            var accessFile   = path.normalize(nodame.config('logger.access_stream'));
            var accessStream = fs.createWriteStream(accessFile, {flags: 'a'});
            var mailer       = nodame.import('mailer');
            var logFile      = path.normalize(nodame.config('logger.error_stream'));
            var logStream    = fs.createWriteStream(logFile, {flags: 'a'});
            var Log          = require('log');
            var Logger       = new Log('debug', logStream);
            break;
    }

    var morgan           = require('morgan');
    var morganFormat     = ':date[clf] :method :status :url <- :referrer :remote-addr :response-time ms - :res[content-length]';

    var error = function () {
        return function (req, res, next) {
            log = (function () {
                var EMERGENCY = {
                    level   : 0,
                    title   : 'EMERGENCY',
                    message : 'System is unusable'
                };
                var ALERT     = {
                    level   : 1,
                    title   : 'ALERT',
                    message : 'Action must be taken immediately'
                };
                var CRITICAL  = {
                    level   : 2,
                    title   : 'CRITICAL',
                    message : 'System is in critical condition'
                };
                var ERROR     = {
                    level   : 3,
                    title   : 'ERROR',
                    message : 'Error condition'
                };
                var WARNING   = {
                    level   : 4,
                    title   : 'WARNING',
                    message : 'Warning condition'
                };
                var NOTICE    = {
                    level   : 5,
                    title   : 'NOTICE',
                    message : 'Normal but significant condition'
                };
                var INFO      = {
                    level   : 6,
                    title   : 'INFO',
                    message : 'Purely informational message'
                };
                var DEBUG     = {
                    level   : 7,
                    title   : 'DEBUG',
                    message : 'Debug only'
                };

                var date = new Date();

                var emergency = function (title, details) {
                    __logger(EMERGENCY, title, details);
                };

                var alert = function (title, details) {
                    __logger(ALERT, title, details);
                };

                var critical = function (title, details) {
                    __logger(CRITICAL, title, details);
                };

                var error = function (title, details) {
                    __logger(ERROR, title, details);
                };

                var warning = function (title, details) {
                    __logger(WARNING, title, details);
                };

                var notice = function (title, details) {
                    __logger(NOTICE, title, details);
                };

                var info = function (title, details) {
                    __logger(INFO, title, details);
                };

                var debug = function (title, details) {
                    __logger(DEBUG, title, details);
                };

                var sentry = function (level, title, details) {
                    var __level;

                    switch (level) {
                        case EMERGENCY:
                        case ALERT:
                        case CRITICAL:
                            __level = 'fatal';
                            break;
                        case ERROR:
                            __level = 'error';
                            break;
                        case WARNING:
                            __level = 'warning';
                            break;
                        case NOTICE:
                        case INFO:
                            __level = 'info';
                            break;
                        case DEBUG:
                            __level = 'debug';
                            break;
                    }

                    var hostname = nodame.config('server.url.hostname');

                    var ua = __useragent();
                    var idDesc = details.split('.')[0];
                    var errorDetails = {
                        id: title,
                        title: idDesc,
                        detail: details
                    };
                    var message = title;

                    if (details) {
                        message += sprintf(': %s', idDesc);
                    }

                    var options = {
                        level: __level,
                        tags: {
                            service: 'desktop',
                            ip: req.ip,
                            real_ip: req.ips[0],
                            device: req.device.type,
                            url: sprintf('%s%s', hostname, req.originalUrl),
                            browser: ua.browser,
                            os: ua.os
                        },
                        extra: {
                            Headers: req.headers,
                            Body: errorDetails
                        }
                    };

                    if (level == ERROR) {
                        sentryClient.captureError(new Error(message), options);
                    } else {
                        sentryClient.captureMessage(message, options);
                    }
                };

                var __useragent = function () {
                    var ua = req.headers['user-agent'];

                    if (ua === undefined) {
                        return {os: '', browser: ''}
                    }

                    var re = /[(][^)]+[)]/gi;
                    var found = ua.match(re);
                    var os = found ? found[0] : 'No OS';
                    os = os.replace(/_/g, '.');
                    os = os.replace(/[()]*/g, '');
                    os = os.replace(/^[a-z0-9 ]+[;][ ]/i, '');

                    var browser = ua.replace(/^.*[)] /g, '');
                    browser = browser.split(' ');
                    browser = browser[0].split('/');

                    re = /(0-9)+/g;
                    var ver = browser[1].split('.');

                    browser = browser[0] + ' ' + ver[0] + '.' + ver[1];

                    return {
                        os: os,
                        browser: browser
                    };
                }

                var __logger = function (level, title, details) {
                    var message = errString(title, details);

                    if (IS_DEV && title !== 404) {
                        console.log('ERROR:'.bold.underline.red);
                        console.log(sprintf('%s %s', date, message));
                    }

                    switch (client) {
                    case 'sentry':
                        sentry(level, title, details);
                        break;

                    default:
                        if (!IS_DEV) {
                            Logger[level.title.toLowerCase()](message);

                            if (level !== DEBUG) {
                                sendMail(level, title, details);
                            }
                        }

                        break;
                    }
                }

                var errString = function (title, details) {
                    details = details || '-';
                    title = IS_DEV ? title.red : title;
                    details = IS_DEV ? details.red : details;

                    var string = sprintf('%s %s %s %s', req.ip, req.path, title, details);
                    return string;
                };

                var sendMail = function (level, title, details) {
                    details = details || '-';
                    var subject = sprintf('[%s (%s)] %s', level.title, level.level, title);
                    var houston = 'Houston, we have a problem!<br>We got a situation here.<br><br>';
                    var html = sprintf('%s<tr><td><strong>Date</strong></td><td>:</td><td>%s</td></tr><tr><td><strong>Level</strong></td><td>:</td><td><span style="font-weight:bold;color:#ff0000">%s (%s)</span></td></tr><tr><td><strong>Level Explanation</strong></td><td>:</td><td>%s</td></tr><tr><td><strong>Remote Address</strong></td><td>:</td><td>%s</td></tr><tr><td><strong>Path</strong></td><td>:</td><td>%s</td></tr><tr><td><strong>Message</strong></td><td>:</td><td>%s</td></tr><tr><td><strong>Details</strong></td><td>:</td><td>%s</td></tr></table>', houston, date, level.title, level.level, level.message, req.ip, req.path, title, details);
                    mailer.alert(subject, html);
                };

                return {
                    emergency: emergency,
                    alert: alert,
                    critical: critical,
                    error: error,
                    warning: warning,
                    notice: notice,
                    info: info,
                    debug: debug
                };
            })();

            if (next) return next();
        }
    };

    var access = function () {
        if (IS_DEV) {
            return morgan(morganFormat);
        } else {
            return morgan(morganFormat, {
                stream: accessStream,
                skip: function (req, res) { return res.StatusCode < 400 }
            });
        }
    };

    return {
        error: error,
        access: access
    };
})();

module.exports = logger;