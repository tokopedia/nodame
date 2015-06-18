var async       = nodame.import('async');
var httpRequest = nodame.import('http-request');
var sha384      = nodame.import('js-sha512').sha384;
var parent      = this;

var clientRedisSession = {};
var keyRedisIdentifier = 'kai:session:';

exports.__getClientRedisSession = function (sessionId) {
    var redis       = nodame.import('redis');
    var redisId     = sessionId.match(/\d+/)[0];
    var redisClient = redis.getClient('session', 'slave', redisId);

    return redisClient;
}

exports.getSessionId = function (req) {
    var configServer = nodame.config('server');
    return req.cookies[configServer.session];
}

exports.initSession = function (req, res, next) {
    var configServer    = nodame.config('server');
    var sessionId       = parent.getSessionId(req);

    if (sessionId) {
        var keyRedis    = keyRedisIdentifier + sessionId;
        var clientRedis = parent.__getClientRedisSession(sessionId);

        clientRedis.get(keyRedis, function (err, reply) {

            // console.log('session err ' + err);
            // console.log('session reply ' + reply);
            if (reply) {
                var session = JSON.parse(reply.toString());
                parent.__setData(req, res, session);

                // console.log('session ' + configServer.session);
                return next();
            } else {
                //async
                async.parallel([
                    function (callback) {
                        parent.__getSession(sessionId, callback);
                    }
                ], function (err, result) {
                    var dataSession = result[0];

                    if (dataSession && dataSession.session && dataSession.session.admin_id) {
                        //check status user active
                        if (dataSession.session.status == 1) {
                            parent.__setData(req, res, dataSession.session);

                            //set session
                            parent.__setSession(req, res, sessionId, dataSession.session);

                            //extend cookie
                            res.cookie(configServer.session, sessionId, {
                                domain  : '.' + configServer.domain,
                                httpOnly: true,
                                expires : new Date(Date.now() +  7 * 24 * 60 * 60 * 1000)
                            });

                            return next();
                        }
                    }

                    //clear session
                    parent.__clearSession(sessionId);

                    res.clearCookie(configServer.session, {
                        domain: '.' + configServer.domain
                    });

                    return next();
                });
            }
        });
    } else {
        parent.__setData(req, res);
        return next();
    }
};

exports.__setData = function (req, res, session) {
    if (session) {
        req.session                 = session;
        res.locals.session          = session;
        req.isAuthenticated         = true;
        res.locals.isAuthenticated  = true;
        req.sessionUserId           = session.admin_id;
        res.locals.sessionUserId    = session.admin_id;

        //datadog
        var datadog                 = nodame.import('datadog');
        var clientStatsD            = datadog.getClient();

        clientStatsD.set('user.login.unique', session.admin_id, ['env:'+ APP_ENV]);
       } else {
        req.session                 = undefined;
        res.locals.session          = undefined;
        req.isAuthenticated         = false;
        res.locals.isAuthenticated  = false;
        req.sessionUserId           = 0;
        res.locals.sessionUserId    = 0;
    }

    // console.log('tes', req.session);
}

exports.__setSession = function (req, res, sessionId, session) {
    if (sessionId && session) {
        var keyRedis    = keyRedisIdentifier + sessionId;
        var clientRedis = parent.__getClientRedisSession(sessionId);
        var expireTime  = 3600 * 3;

        if (session.remember_me == 1) {
            expireTime = 3600 * 24;
        }

        clientRedis.set(keyRedis, JSON.stringify(session));
        //set expire
        clientRedis.expire(keyRedis, expireTime);
    }
}

exports.__clearSession = function (sessionId) {
    if (sessionId) {
        var keyRedis    = keyRedisIdentifier + sessionId;
        var clientRedis = parent.__getClientRedisSession(sessionId);
        clientRedis.del(keyRedis);
    }
}

exports.__getSession = function (sessionId, callback) {
    var url         = nodame.config('server.url.api_session');
    var secret      = nodame.import('secret');
    var hash        = secret.getHash('session', sessionId);
    var apiReqUrl   = url + '/user.pl?ck=' + sessionId + '&h=' + hash;

    var http = httpRequest.new(apiReqUrl, 0, 'session');
    http.get(function (result) {
        callback(null, result);
    });
}