var measure = nodame.import('measure');

var httpRequest = module.exports = (function () {
    var querystring = nodame.import('query-string');

    var init = function (url, userid, metricName) {
        var options = getOptions(url, userid);
        return prototype.__init(options, metricName);
    };

    var parseUrl = function (url) {
        var re      = /^(?:((http[s]{0,1}):\/\/))?([a-z0-9-_\.]+)(?:(:[0-9]+))?(.*)$/
        var found   = url.match(re);

        var protocol = found[2] || 'http';
        var port = found[4] !== undefined ? found[4] : (protocol == 'http' ? ':80' : ':443');
        var parsedUrl = {
            protocol: protocol,
            host: found[3],
            port: (port).replace(':', ''),
            path: found[5]
        };

        return parsedUrl;
    };

    var getToken = function (userid) {
        if (userid === undefined) {
            userid = "0";
        }

        var token = {
            "user_id": String(userid)
        }

        token = new Buffer(JSON.stringify(token)).toString('base64');
        token = 'Tokopedia ' + token;

        return token;
    };

    var getOptions = function (url, userid) {
        var parsedUrl = parseUrl(url);
        var token = getToken(userid);

        var options = {
            protocol    : parsedUrl.protocol,
            host        : parsedUrl.host,
            port        : parsedUrl.port,
            path        : parsedUrl.path,
            headers     : {
                'Authorization' : token,
                'User-Agent'    : 'TKPD_WS'
            }
        }

        return options;
    };

    var prototype = (function () {
        var GET     = 'GET';
        var POST    = 'POST';
        var PUT     = 'PUT';
        var DELETE  = 'DELETE';
        var __request;
        var __options;
        var request = {
            http    : nodame.import('http'),
            https   : nodame.import('https')
        };
        var timeout = 5;
        var protocol = 'http';
        var __metricName = '';

        var __init = function (options, metricName) {
            if (metricName) {
                __metricName = 'http.request.kai.' + metricName;
            }
            protocol = options.protocol;
            __request = request[protocol];
            delete options.protocol;
            __options = options;
            return this;
        };

        var parse = function (data) {
            var result;

            try {
                result = JSON.parse(data);
            } catch (err) {
                var error = {
                    id: '110101',
                    title: 'Invalid response data',
                    detail: sprintf('Failed in fetching data from %s://%s:%s%s.\n\nResponse Data:\n%s', protocol, __options.host, String(__options.port), __options.path, data)
                };

                result = {
                    errors: [error]
                };

                log.critical(error.id, sprintf('%s. %s', error.title, error.detail));
            }

            return result;
        };

        var setTimeout = function (second) {
            timeout = second;
            return this;
        }

        var get = function (callback) {
            run(GET, '', function (result) {
                callback(result);
            });
        };

        var postRaw = function (data, callback) {
            post('raw', data, function (result) {
                callback(result);
            });
        };

        var postForm = function (data, callback) {
            post('form', data, function (result) {
                callback(result);
            });
        };

        var post = function (type, data, callback) {
            __post(POST, type, data, function (result) {
                callback(result);
            });
        };

        var putRaw = function (data, callback) {
            put('raw', data, function (result) {
                callback(result);
            });
        };

        var putForm = function (data, callback) {
            put('form', data, function (result) {
                callback(result);
            });
        };

        var put = function (type, data, callback) {
            __post(PUT, type, data, function (result) {
                callback(result);
            });
        };

        var delRaw = function (data, callback) {
            del('raw', data, function (result) {
                callback(result);
            });
        };

        var delForm = function (data, callback) {
            del('form', data, function (result) {
                callback(result);
            });
        };

        var del = function (type, data, callback) {
            __post(DELETE, type, data, function (result) {
                callback(result);
            });
        };

        var __post = function (method, type, data, callback) {
            var __data = {
                type: type
            }

            if (type == 'form') {
                __data.body = querystring.stringify(data);
            } else {
                __data.body = JSON.stringify(data);
            }

            run(method, __data, function (result) {
                callback(result);
            });
        };

        var rebuild = function (method, data) {
            var options = __options;
            options.method = method;

            if (data !== '') {
                var contentType = data.type == 'form' ? 'application/x-www-form-urlencoded' : 'application/vnd.api+json';
                options.body = data.body;
                options.headers['Content-Type'] = contentType;
                options.headers['Content-Length'] = data.body.length;
            }

            return options;
        };

        var run = function (method, data, callback) {
            var options = rebuild(method, data);

            var req = __request.request(options, function (res) {
                var done;

                if (__metricName !== '') {
                    done = measure.measure('httpRequest');
                }

                var __data = '';

                res.on('data', function (chunk) {
                    __data += String(chunk);
                });

                res.on('end', function () {
                    if (done) {
                        var datadog = nodame.import('datadog');
                        var clientStatsD = datadog.getClient();
                        clientStatsD.histogram(__metricName, done(), ['env:'+ APP_ENV]);
                    }

                    callback(parse(__data));
                });
            });

            req.on('error', function (err) {
                var error = {
                    id: '110102',
                    title: 'Request timeout',
                    detail: sprintf('Can\'t reach server at %s://%s:%s%s', protocol, options.host, String(options.port), options.path)
                };

                var result = {
                    errors: [error]
                };

                if (!req.socket.destroyed) {
                    log.alert(error.id, sprintf('%s. %s', error.title, error.detail));
                    // callback(result);
                }
            });

            if (method == POST || method == DELETE || method == PUT) {
                req.write(options.body);
            }

            req.setTimeout(timeout * 1000, function () {
                var error = {
                    id: '110102',
                    title: 'Request timeout',
                    detail: sprintf('Can\'t reach server at %s://%s:%s%s with data: %s', protocol, options.host, String(options.port), options.path, options.body)
                };

                var result = {
                    errors: [error]
                };

                log.alert(error.id, sprintf('%s. %s', error.title, error.detail));
                req.socket.destroy();
                req.abort();
                callback(result);
            });

            req.end();
        };

        return {
            __init: __init,
            setTimeout: setTimeout,
            get: get,
            post: post,
            postForm: postForm,
            postRaw: postRaw,
            put: put,
            putForm: putForm,
            putRaw: putRaw,
            del: del,
            delForm: delForm,
            delRaw: delRaw
        };
    })();

    return {
        new: init
    };

})();
