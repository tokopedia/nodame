function errors(app) {
    // catch 404 and forward to error handler
    app.use(function(req, res, next) {
        var err = new Error('Not Found');
        err.status = 404;
        next(err);
    });
    
    app.use(errorsHandler);
}

function errorsHandler(err, req, res, next) {
    var utilHtml = helper.load.util('html');
    res.status(err.status || 500);

    // development error handler
    // will print stacktrace
    var data = {
        message: getErrMessage(err.message),
        error: err,
        isDev: IS_DEV
    }

    // production error handler
    // no stacktraces leaked to user
    if (!IS_DEV) {
        data.error = {
            status: err.status
        }
    }

    var errCode = getErrCode(err, req);

    if (errCode >= 500) {
        log.critical(errCode, data.message);
    } else {
        log.info(errCode, data.message);
    }

    html = utilHtml.new(req, res);
    html.stash.set('data', data);
    html.headTitle('Tokopedia');
    html.headDescription('tokopedia');
    html.render({
        module: 'errors',
        file: errCode
    });

    return;
}

function getErrMessage(text) {
    var text = text + '\n' +  getStackTrace();
    return text;
}

function getStackTrace() {
  var obj = {};
  Error.captureStackTrace(obj, getStackTrace);
  return obj.stack;
}

function getErrCode(err, req) {
    var errors = new Array(404, 500, 503);
    return errors.indexOf(err.status) < 0 ? '500' : String(err.status);
}

module.exports = errors;
