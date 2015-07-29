/*
 * @author  Argi Karunia <arugikaru@yahoo.co.jp>
 * @author  Originally by Teddy Hong <teddy.hong11@gmail.com>
 * @link    https://github.com/tokopedia/nodame
 * @license http://opensource.org/licenses/MIT
 *
 * @version 1.0.0
 */

var async       = require('async');
var request     = require('nodame/request');
var sha384      = require('js-sha512').sha384;
var parent      = this;
var cookieCfg   = nodame.config('cookie');

var clientRedisSession = {};
var keyRedisIdentifier = nodame.config('app.name') + ':session:';

exports.__getClientRedisSession = function (sessionId) {
    // TODO: Make flexible
    var redis       = require('nodame/redis');
    var redisId     = sessionId.match(/\d+/)[0];
    var redisClient = redis.getClient('session', 'slave', redisId);

    return redisClient;
};

exports.getSessionId = function (req) {
    return req.cookies[cookieCfg.session];
};

exports.initSession = function (req, res, next) {
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
                            res.cookie(nodame.config.session, sessionId, {
                                domain  : '.' + cookieCfg.domain,
                                httpOnly: true,
                                expires : new Date(Date.now() +  7 * 24 * 60 * 60 * 1000)
                            });

                            return next();
                        }
                    }

                    //clear session
                    parent.__clearSession(sessionId);

                    res.clearCookie(cookieCfg.session, {
                        domain: '.' + cookieCfg.domain
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
        log.stat.set('user.login.unique', session.admin_id, ['env:'+ nodame.env()]);
    } else {
        req.session                 = undefined;
        res.locals.session          = undefined;
        req.isAuthenticated         = false;
        res.locals.isAuthenticated  = false;
        req.sessionUserId           = 0;
        res.locals.sessionUserId    = 0;
    }
};

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
};

exports.__clearSession = function (sessionId) {
    if (sessionId) {
        var keyRedis    = keyRedisIdentifier + sessionId;
        var clientRedis = parent.__getClientRedisSession(sessionId);
        clientRedis.del(keyRedis);
    }
};

exports.__getSession = function (sessionId, callback) {
    var url         = nodame.config('url.api.session');
    var secret      = require('nodame/secret');
    var hash        = secret.getHash('session', sessionId);
    var apiReqUrl   = sprintf('%s?ck=%s&h=%s', url, sessionId, hash);

    var http = request.new(apiReqUrl, 0, 'session');
    http.get(function (result) {
        callback(null, result);
    });
};
