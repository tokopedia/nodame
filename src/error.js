/**
 * @author  Argi Karunia <arugikaru@yahoo.co.jp>
 * @link    https://github.com/tokopedia/nodame
 * @license http://opensource.org/licenses/MIT
 *
 * @version 1.0.0
 */

var config = nodame.config('logger');

function errors(app) {
    // catch 404 and forward to error handler
    app.use(function (req, res, next) {
        var err     = new Error('Not Found');
        err.status  = 404;
        next(err);
    });

    app.use(errorsHandler);
}

function errorsHandler(err, req, res, next) {
    var utilHtml    = require('./html');
    var errCode     = err.status || 500;
    var errCodeView = getErrCodeView(err, req);

    res.status(errCode);

    // development error handler
    // will print stacktrace
    var data = {
        message: errCode !== 404 ? getErrMessage(err.message) : 'Page Not Found',
        error: err,
        isDev: nodame.isDev()
    };

    // production error handler
    // no stacktraces leaked to user
    if (!nodame.isDev()) {
        data.error = {
            status: errCode
        };
    }


    if (errCode >= 500) {
        log.critical(errCode, data.message);
    } else {
        log.info(errCode, data.message);
    }

    // Datadog
    var datadogKey = config.clients.datadog.key.error;
    log.stat.increment(datadogKey, ['env:' + nodame.env(), 'status:' + errCode]);

    html = utilHtml.new(req, res);
    html.stash.set('data', data);
    html.headTitle(nodame.config('app.title'));
    html.headDescription(nodame.config('app.desc'));
    html.render({
        module: 'errors',
        file: errCodeView
    });

    return;
}

function getErrMessage(msg) {
    var text = msg + '\n' +  getStackTrace();
    return text;
}

function getStackTrace() {
  var obj = {};
  Error.captureStackTrace(obj, getStackTrace);
  return obj.stack;
}

function getErrCodeView(err, req) {
    var errors = new Array(404, 500, 503);
    return errors.indexOf(err.status) < 0 ? '500' : String(err.status);
}

module.exports = errors;
