var path    = nodame.import('path');
var uuid    = nodame.import('node-uuid');
var md5     = nodame.import('MD5');
var parse   = nodame.import('parse-duration');

exports.new = function (req, res) {
    var stash = {
        __stash: new Object(),
        __get: function (obj, params) {
            if (params.length == 0) {
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
    }

    var __initHead = function () {
        var configServer = nodame.config('server');

        //head title
        if (!stash.get('headTitle')) {
            stash.set('headTitle', 'Pesan Tiket Kereta Api Online, Harga Promo dan Murah - Tokopedia');
        }

        //head desctiption
        if (!stash.get('headDescription')) {
            stash.set('headDescription', 'Cari dan Beli Tiket Kereta Api menjadi lebih mudah di Tokopedia. Pesan dan Reservasi tiket KAI langsung secara online. Praktis, aman dan nyaman, semua ada di Tokopedia.');
        }

        //refback
        if (res && res.locals.refback) {
            stash.set('refback', res.locals.refback);
        }
        if (!stash.get('refback')) {
            stash.set('refback', configServer.url.base)
        }
    }

    var assetsName = function (assetsName) {
        stash.set('assetsName', assetsName);
    }

    var showDrawer = function (activeMenu) {
        stash.set('showMenu', {
            active: activeMenu
        });
    }

    var showRefback = function (title, refback) {
        stash.set('refback', refback);
        stash.set('refbackTitle', title);
    }

    var headTitle = function (title, page) {
        var headTitle;
        if (title.toLowerCase() == 'tokopedia') {
            headTitle = 'Tokopedia';
        } else {
            headTitle = title + ' | Tokopedia';

            if (page) {
                headTitle = headTitle + ', ' + 'Halaman' + ' ' + page;
            }
        }
        stash.set('headTitle', headTitle);
    }

    var headDescription = function (description) {
        stash.set('headDescription', description);
    }

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
    }

    var setFlashMessages = function (type, text) {
        var redis = nodame.import('redis');
        var fm = req.cookies.fm;
        if (!fm) {
            fm = uuid.v4();
            res.cookie('fm', fm, {
                domain: '.' + nodame.config('server.domain'),
                expires: new Date(Date.now() + 600000),
                httpOnly: true
            });
        }
        var redisClient = redis.getClient('session', 'master', 1);
        var keyFm = 'flashMessages:' + fm;
        // console.log(keyFm);
        redisClient.rpush(keyFm, JSON.stringify({'type': type, 'text': text}));
        redisClient.expire(keyFm, 600);
    }

    var __initFlashMessages = function (callback) {
        //flash messages
        if (req && req.cookies) {
            var fm = req.cookies.fm;

            if (fm) {
                var redis = nodame.import('redis');
                var redisClient = redis.getClient('session', 'slave', 1);

                var keyFm = 'flashMessages:' + fm;
                // console.log(keyFm);
                redisClient.lrange(keyFm, 0, -1, function (err, reply) {
                    if (reply) {
                        // console.log(reply);
                        for (var i in reply) {
                            var msg = JSON.parse(reply[i]);
                            setMessages(msg.type, msg.text)
                        }
                        redisClient.del(keyFm);

                        // console.log('clearCookie start', fm);
                        res.clearCookie('fm', {
                            domain: '.' + nodame.config('server.domain')
                        });
                        // console.log('clearCookie end');

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
    }

    var render = function (args) {
        __initFlashMessages(function () {
            __initHead();
            var viewPath = path.view(req, args.module, args.file);
            res.render(viewPath, stash.__stash, function (err, html) {
                if (err) {
                    res.send(sprintf('Cannot find view %s', viewPath));
                } else {
                    if (args.cache) {
                        var redis       = nodame.import('redis');
                        var redisClient = redis.getClient('html', 'master', 1);
                        var hostname    = nodame.config('server.url.hostname');
                        var uri         = req.originalUrl;
                        var url         = path.normalize(hostname + uri);
                        var keyRedis = 'html:' + md5(url);
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

    }

    var renderCache = function (callback) {
        var redis       = nodame.import('redis');
        var redisClient = redis.getClient('html', 'slave', 1);
        var hostname    = nodame.config('server.url.hostname');
        var uri         = req.originalUrl;
        var url         = path.normalize(hostname + uri);
        var keyRedis    = 'html:' + md5(url);

        if (nodame.config('app.html_cache')) {
            redisClient.hget(keyRedis, req.device.type, function (err, reply) {
                if (reply) {
                    res.send(reply.toString());
                    callback(true);
                } else {
                    callback(false);
                }
            });
        } else {
            callback(false);
        }
    }

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
    }
}