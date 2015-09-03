/**
 * @author  Argi Karunia <arugikaru@yahoo.co.jp>
 * @link    https://github.com/tokopedia/nodame
 * @license http://opensource.org/licenses/MIT
 *
 * @version 1.0.0
 */

var measure = require('measure');

if (nodame.config('session.request_token')) {
    var requestTokenModule = nodame.config('session.request_token_module');
    var requestToken = nodame.require('module/' + requestTokenModule);
}

var httpRequest = (function () {
    var querystring = require('query-string');

    var init = function (url) {
        var options = getOptions(url);
        return prototype.__init(options);
    };

    var parseUrl = function (url) {
        var re      = /^(?:((http[s]{0,1}):\/\/))?([a-z0-9-_\.]+)(?:(:[0-9]+))?(.*)$/;
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
        if (nodame.config('session.request_token')) {
            return requestToken.get(userid);
        } else {
            return null;
        }
    };

    var getOptions = function (url) {
        var parsedUrl = parseUrl(url);

        var options = {
            protocol    : parsedUrl.protocol,
            host        : parsedUrl.host,
            port        : parsedUrl.port,
            path        : parsedUrl.path,
            headers     : {
                'User-Agent'    : 'curl/7.43.0'
            }
        };

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
            http    : require('http'),
            https   : require('https')
        };
        var timeout = 5;
        var protocol = 'http';
        var __metricName = '';

        var __init = function (options) {
            protocol = options.protocol;
            __request = request[protocol];
            delete options.protocol;
            __options = options;
            return this;
        };

        var header = function (key, val) {
            if (__options.headers[key]) {
                delete __options.headers[key];
            }

            __options.headers[key] = val;
        };
        
        var base64_auth = function (key, userid) {
            if (__options.headers['Authorization']) {
                delete __options.headers['Authorization'];
            }
            
            userid = userid | String(0);
            var token = {
                user_id: String(userid)
            };

            token = new Buffer(JSON.stringify(token)).toString('base64');
            token = sprintf('%s %s', key, token);

            __options.headers['Authorization'] = token;
        }
        
        var set_metricname = function (key, metricName){
            if (metricName) {
                __metricName = key + metricName;
            }
        }

        var parse = function (contentType, data) {
            var result;

            if (!(contentType)) {
                return data;
            }

            if(contentType.match(/xml|html/) !== null && data.substr(0, 1) !== '{'){
                return data;
            }

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
        };

        var get = function (callback) {
            run(GET, '', function (result) {
                callback(result);
            });
        };

        var post = function (content_type, data, callback) {
            __post(POST, content_type, data, function (result) {
                callback(result);
            });
        };

        var put = function (content_type, data, callback) {
            __post(PUT, content_type, data, function (result) {
                callback(result);
            });
        };

        var del = function (content_type, data, callback) {
            __post(DELETE, content_type, data, function (result) {
                callback(result);
            });
        };

        var __post = function (method, type, data, callback) {
            var __data = {
                type: type
            };
 
            switch(type) {
                case 'form':
                    header('Content-Type', 'application/x-www-form-urlencoded');
                    __data.body = querystring.stringify(data);
                    break;
                case 'json':
                    header('Content-Type', 'application/vnd.api+json');
                    __data.body = JSON.stringify(data);
                    break;
                case 'xml':
                    header('Content-Type', 'application/xml');
                    __data.body = data;
                    break;
                default:
                    header('Content-Type', type);
                    __data.body = data;
            }

            run(method, __data, function (result) {
                callback(result);
            });
        };

        var rejectUnauthorized = function () {
            __options.rejectUnauthorized = false;
        };

        var set = function (key, value) {
            if (__options[key] === undefined) {
                __options[key] = value;
            }
        };

        var rebuild = function (method, data) {
            var options = __options;
            options.method = method;

            if (data !== '') {
                options.body = data.body;
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
                        log.stat.histogram(__metricName, done(), ['env:'+ nodame.env()]);
                    }
                    callback(parse(res.headers['content-type'], __data));
                });
            });

            req.on('error', function (err) {
                console.log(err)
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
            put: put,
            del: del,
            header: header,
            base64_auth: base64_auth,
            set_metricname: set_metricname,
            set: set,
            rejectUnauthorized: rejectUnauthorized
        };
    })();

    return {
        new: init
    };

})();

module.exports = httpRequest;