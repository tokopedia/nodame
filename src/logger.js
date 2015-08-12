/**
 * @author  Argi Karunia <arugikaru@yahoo.co.jp>
 * @link    https://github.com/tokopedia/nodame
 * @license http://opensource.org/licenses/MIT
 *
 * @version 1.0.0
 */

var LOGGER = nodame.config('logger');
var CLIENT = LOGGER.clients;
var FS     = require('fs')

EMERGENCY = {
    level   : 0,
    title   : 'EMERGENCY',
    message : 'System is unusable'
};
ALERT     = {
    level   : 1,
    title   : 'ALERT',
    message : 'Action must be taken immediately'
};
CRITICAL  = {
    level   : 2,
    title   : 'CRITICAL',
    message : 'System is in critical condition'
};
ERROR     = {
    level   : 3,
    title   : 'ERROR',
    message : 'Error condition'
};
WARNING   = {
    level   : 4,
    title   : 'WARNING',
    message : 'Warning condition'
};
NOTICE    = {
    level   : 5,
    title   : 'NOTICE',
    message : 'Normal but significant condition'
};
INFO      = {
    level   : 6,
    title   : 'INFO',
    message : 'Purely informational message'
};
DEBUG     = {
    level   : 7,
    title   : 'DEBUG',
    message : 'Debug only'
};

var logger = (function () {
    var self = this;

    if (nodame.isDev()) {
        var colors          = require('colors');
    }

    if (LOGGER.enable) {
        if (CLIENT.datadog.enable) {
            var datadog         = require('./datadog');
            var clientStatsD    = datadog.getClient();
        }

        if (CLIENT.sentry.enable) {
            var raven        = require('raven');
            var sentryClient = new raven.Client(CLIENT.sentry.dns);
        }

        if (CLIENT.syslog.enable) {
            var fs           = require('fs');
            var path         = require('./path');
            var outputFile   = path.safe(CLIENT.syslog.output_stream);
            var outputStream = fs.createWriteStream(outputFile, {flags: 'a'});
            var mailer       = require('./mailer');
            var logFile      = path.safe(CLIENT.syslog.error_stream);
            var logStream    = fs.createWriteStream(logFile, {flags: 'a'});
            var Log          = require('log');
            var Logger       = new Log('debug', logStream);
        }

        if (CLIENT.morgan.enable) {
            var morgan       = require('morgan');
            var morganFormat = ':date[clf] :method :status :url <- :referrer :remote-addr :response-time ms - :res[content-length]';
        }
    }

    _register_errors = function() {

        var filename = nodame.appPath() + '/locales/errors.json';

        var buff = FS.readFileSync(filename, "utf8");
        error_codes = JSON.parse(buff);

        return nodame.set('errors', error_codes);
    }();

    var error = function () {
        return function (req, res, next) {
            log = (function () {

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

                    var hostname = nodame.config('url.hostname');
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
                            environment: nodame.env(),
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
                        return {os: '', browser: ''};
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
                };

                var __logger = function (level, title, details) {
                    if (LOGGER.enable) {
                        var message = errString(title, details);

                        if (nodame.isDev() && title !== 404) {
                            console.log('ERROR:'.bold.underline.red);
                            console.log(sprintf('%s %s', date, message));
                        }

                        if (CLIENT.sentry.enable) {
                            sentry(level, title, details);
                        }

                        if (CLIENT.syslog.enable) {
                            Logger[level.title.toLowerCase()](message);
                        }

                        if (CLIENT.email.enable) {
                            if (level !== DEBUG) {
                                sendMail(level, title, details);
                            }
                        }
                    }
                };

                var errString = function (title, details) {
                    details = details || '-';
                    title = nodame.isDev() ? title.red : title;
                    details = nodame.isDev() ? details.red : details;

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

                var stat = (function () {
                    if (LOGGER.enable && CLIENT.datadog.enable) {
                        return datadog.getClient();
                    }

                    return FakeDatadogClient;
                })();

                var code = function (code_str, level_obj) {
                    var use_english = true;
                    if(use_english){
                        err_message = nodame.settings.errors[code_str].en
                    } else {
                        err_message = nodame.settings.errors[code_str].id
                    }

                    pattern = new RegExp('[^0-9]+')
                    err_code = code_str.replace(pattern,"")

                    switch(level_obj.level) {
                        case 0:
                            emergency(err_code, err_message)
                            break;
                        case 1:
                            alert(err_code, err_message)
                            break;
                        case 2:
                            critical(err_code, err_message)
                            break;
                        case 3:
                            error(err_code, err_message)
                            break;
                        case 4:
                            warning(err_code, err_message)
                            break;
                        case 5:
                            notice(err_code, err_message)
                            break;
                        case 6:
                            info(err_code, err_message)
                            break;
                        case 7:
                            debug(err_code, err_message)
                            break;
                    }
                }

                return {
                    emergency: emergency,
                    alert: alert,
                    critical: critical,
                    error: error,
                    warning: warning,
                    notice: notice,
                    info: info,
                    debug: debug,
                    stat: stat,
                    code: code
                };
            })();

            if (next) return next();
        };
    };

    var output = function () {
        if (LOGGER.enable && CLIENT.morgan.enable) {
            if (!nodame.isDev() && CLIENT.syslog.enable) {
                return morgan(outputFile, {
                    stream: outputStream,
                    skip: function (req, res) {
                        return res.StatusCode < 400;
                    }
                });
            } else {
                return morgan(morganFormat);
            }
        } else {
            return function (req, res, next) {
                return next();
            };
        }
    };

    return {
        error: error,
        output: output
    };
})();

var FakeDatadogClient = {
    timing      : function () {},
    increment   : function () {},
    decrement   : function () {},
    gauge       : function () {},
    histogram   : function () {},
    set         : function () {},
    update_stats: function () {},
    send_data   : function () {},
    send        : function () {},
    close       : function () {}
};

module.exports = logger;
