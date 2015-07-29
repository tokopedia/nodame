/**
 * @author  Argi Karunia <arugikaru@yahoo.co.jp>
 * @author  Originally by Teddy Hong <teddy.hong11@gmail.com>
 * @link    https://github.com/tokopedia/nodame
 * @license http://opensource.org/licenses/MIT
 *
 * @version 1.0.0
 */

var path    = require('path');
var View    = require('./view');
var uuid    = require('node-uuid');
var md5     = require('md5');
var parse   = require('parse-duration');

view = new View();

exports.new = function (req, res) {
    var stash = {
        __stash: {},
        __get: function (obj, params) {
            if (params.length === 0) {
                return obj;
            }

            if (params.length > 1) {
                obj = obj[params[0]];
                params.shift();
                return this.__get(obj, params);
            } else {
                obj = obj[params[0]];
                return obj;
            }
        },
        set: function (key, value) {
            if (key) {
                this.__stash[key] = value;
            }
        },
        get: function (params) {
            params = params.split('.');
            return this.__get(this.__stash, params);
        }
    };

    var __initHead = function () {
        //head title
        if (!stash.get('headTitle')) {
            stash.set('headTitle', nodame.config('app.title'));
        }

        //head desctiption
        if (!stash.get('headDescription')) {
            stash.set('headDescription', nodame.config('app.desc'));
        }

        //refback
        if (res && res.locals.refback) {
            stash.set('refback', res.locals.refback);
        }
        if (!stash.get('refback')) {
            stash.set('refback', nodame.config('url.base'));
        }
    };

    var assetsName = function (assetsName) {
        stash.set('assetsName', assetsName);
    };

    var showDrawer = function (activeMenu) {
        stash.set('showMenu', {
            active: activeMenu
        });
    };

    var showRefback = function (title, refback) {
        stash.set('refback', refback);
        stash.set('refbackTitle', title);
    };

    var headTitle = function (title, page) {
        var headTitle;
        var defTitle    = nodame.config('app.title');
        var separator   = nodame.config('app.title_separator');
        // TODO: Change with i18n
        var pageTxt     = 'Halaman';

        if (title.toLowerCase() == defTitle) {
            headTitle = defTitle;
        } else {
            headTitle = sprintf('%s %s %s', title, separator, defTitle);

            if (page) {
                headTitle = sprintf('%s, %s %s', headTitle, pageTxt, page);
            }
        }
        stash.set('headTitle', headTitle);
    };

    var headDescription = function (description) {
        stash.set('headDescription', description);
    };

    var setMessages = function (type, text) {
        var messages = stash.get('messages');
        if (messages === undefined) {
            messages = [];
        }
        messages.push({
            type: type,
            text: text
        });

        stash.set('messages', messages);
    };

    var setFlashMessages = function (type, text) {
        var redis = require('./redis');
        var fm = req.cookies.fm;

        if (!fm) {
            fm = uuid.v4();
            res.cookie('fm', fm, {
                domain: '.' + nodame.config('cookie.domain'),
                expires: new Date(Date.now() + 600000),
                httpOnly: true
            });
        }

        var redisClient = redis.getClient('session', 'master', 1);
        var keyFm = 'flashMessages:' + fm;

        redisClient.rpush(keyFm, JSON.stringify({'type': type, 'text': text}));
        redisClient.expire(keyFm, 600);
    };

    var __initFlashMessages = function (callback) {
        //flash messages
        if (req && req.cookies) {
            var fm = req.cookies.fm;

            if (fm) {
                var redis = require('./redis');
                var redisClient = redis.getClient('session', 'slave', 1);

                var keyFm = 'flashMessages:' + fm;

                redisClient.lrange(keyFm, 0, -1, function (err, reply) {
                    if (reply) {
                        for (var i in reply) {
                            var msg = JSON.parse(reply[i]);
                            setMessages(msg.type, msg.text);
                        }
                        redisClient.del(keyFm);

                        res.clearCookie('fm', {
                            domain: '.' + nodame.config('cookie.domain')
                        });

                        callback();
                    } else {
                        callback();
                    }
                });
            } else {
                callback();
            }
        } else {
            callback();
        }
    };

    var render = function (args) {
        __initFlashMessages(function () {
            __initHead();
            var viewPath = view.path(req, args.module, args.file);

            res.render(viewPath, stash.__stash, function (err, html) {
                if (err) {
                    log.emergency('Fatal error in parsing view', err.stack);
                    res.send(sprintf('Cannot find or parse view %s', viewPath));
                } else {
                    if (args.cache) {
                        var key         = '';
                        var redis       = require('./redis');
                        var redisClient = redis.getClient('html', 'master', 1);
                        var hostname    = nodame.config('url.hostname');
                        var uri         = req.originalUrl;
                        var url         = path.normalize(hostname + uri);

                        if (args.key !== null || args.key !== undefined) {
                            key = args.key;
                        }

                        var keyRedis = 'html:' + md5(url + key);
                        redisClient.hset(keyRedis, req.device.type, html, function (err, reply) {
                                if (err) {
                                    console.log('hset render err', err);
                                } else {
                                    redisClient.expire(keyRedis, parse(args.cache) / 1000);
                                }
                        });
                    }
                    res.send(html);
                }
            });
        });

    };

    var renderCache = function (key, callback) {
        var redis       = require('./redis');
        var redisClient = redis.getClient('html', 'slave', 1);
        var hostname    = nodame.config('url.hostname');
        var uri         = req.originalUrl;
        var url         = path.normalize(hostname + uri);

        if (key === null || key === undefined) {
            key = '';
        }

        var keyRedis    = 'html:' + md5(url + key);

        var build_time  = nodame.settings.build.time;
        var time        = Math.floor(Date.now() / 1000);
        var purge_time  = nodame.config('view.purge_time');
        var time_diff   = time - build_time;
        var is_purge    = time_diff < purge_time;

        if (nodame.config('view.cache')) {
            if (is_purge) {
                callback(false);
            } else {
                redisClient.hget(keyRedis, req.device.type, function (err, reply) {
                    if (reply) {
                        res.send(reply.toString());
                        callback(true);
                    } else {
                        callback(false);
                    }
                });
            }
        } else {
            callback(false);
        }
    };

    var locales = function (locales) {
        stash.set('locales', locales);
    };

    return {
        stash: stash,
        assetsName: assetsName,
        showDrawer: showDrawer,
        showRefback: showRefback,
        headTitle: headTitle,
        headDescription: headDescription,
        setMessages: setMessages,
        setFlashMessages: setFlashMessages,
        locales: locales,
        render: render,
        renderCache: renderCache,
        req: req,
        res: res
    };
};
