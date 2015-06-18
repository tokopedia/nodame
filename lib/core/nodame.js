var numeral = require('numeral');
var path    = require('path');

module.exports = (function () {
    var settings = {};

    var set = function (key, obj) {
        if (key === undefined || obj === undefined) {
            throw new Errors('Invalid settings set parameters.');
        }

        settings[key] = obj;
    };

    var express = require('express');

    var router  = function () {
        return this.express.Router();
    }

    var sysPath = function () {
        return path.normalize(__dirname + '/..');
    }

    var appPath = function () {
        return path.normalize(sysPath() + '/../../..');
    }

    var config  = function (key) {
        var read = function (obj, params) {
            if (params.length == 0) {
                return obj;
            }

            if (params.length > 1) {
                obj = obj[params[0]];
                params.shift();
                return read(obj, params);
            } else {
                obj = obj[params[0]];
                return obj;
            }
        };

        var get = function () {
            key = key.split('.');
            return read(settings.config, key);
        }

        return get();
    };

    var __getFilePath = function (module, name) {
        var dirname = module === 'my_modules' ? sysPath() : appPath();
        return path.normalize(sprintf('%s/%s/%s', dirname, module, name));
    }

    var load = function (name) {
        try {
            return require(__getFilePath('my_modules', name));
        } catch (e) {
            return require(name);
        }
    };

    var service = function (name) {
        return require(__getFilePath('services', name));
    };

    var handler = function (name) {
        return require(__getFilePath('handlers', name));
    };

    var middleware = function (name) {
        return require(__getFilePath('middlewares', name));
    }

    var enforceMobile = function () {
        var self = this;

        return function (req, res, next) {
            switch (ENFORCE_MOBILE) {
                case 'soft':
                    req.device.type = 'phone';
                    break;
                case 'hard':
                    req.device.type = 'desktop';
                    html = self.import('html').new(req, res);
                    html.headTitle('Tokopedia');
                    html.headDescription('tokopedia');
                    html.render({
                        module: 'errors',
                        file: 'interrupt'
                    });
                    break;
            }

            if (next && ENFORCE_MOBILE !== 'hard') return next();
        }
    };

    var locals = function (app) {
        var self = this;
        var qs = require('query-string');
        var configs = {
            url: this.config('server.url'),
            app: this.config('app'),
            assets: this.config('assets')
        };

        return function (req, res, next) {
            app.locals.helper = {
                time: function (num) {
                    return String(num).replace(/([0-9]{2})([0-9]{2})/, '$1:$2 WIB');
                },
                leadZero: function (num) {
                    return ('0' + num).slice(-2);
                },
                date: function (date, format) {
                    var format = format || 'normal';
                    var date = new Date(date);
                    var weekdays = {
                        Sun: 'Minggu',
                        Mon: 'Senin',
                        Tue: 'Selasa',
                        Wed: 'Rabu',
                        Thu: 'Kamis',
                        Fri: 'Jumat',
                        Sat: 'Sabtu'
                    };

                    var months = {
                        Jan: {
                            word: 'Januari',
                            num: '1'
                        },
                        Feb: {
                            word: 'Februari',
                            num: '2'
                        },
                        Mar: {
                            word: 'Maret',
                            num: '3'
                        },
                        Apr: {
                            word: 'April',
                            num: '4'
                        },
                        May: {
                            word: 'Mei',
                            num: '5'
                        },
                        Jun: {
                            word: 'Juni',
                            num: '6'
                        },
                        Jul: {
                            word: 'Juli',
                            num: '7'
                        },
                        Aug: {
                            word: 'Agustus',
                            num: '8'
                        },
                        Sep: {
                            word: 'September',
                            num: '9'
                        },
                        Oct: {
                            word: 'Oktober',
                            num: '10'
                        },
                        Nov: {
                            word: 'November',
                            num: '11'
                        },
                        Dec: {
                            word: 'Desember',
                            num: '12'
                        }
                    }

                    return date.toString().replace(/^([a-z]{1,3}) ([a-z]{1,3}) ([0-9]{1,2}) ([0-9]{1,4}) ([0-9]{1,2}):([0-9]{1,2}):([0-9]{1,2}) GMT([-+][0-9]{1,4}) (\([a-z ]+\))$/i, function (match, $1, $2, $3, $4, offset, original) {

                        var res = '';

                        switch (format) {
                            case 'normal':
                                res = weekdays[$1] + ', ' + $3 + ' ' + months[$2].word + ' ' + $4;
                                break;
                            case 'short':
                                res = ('0' + $3).slice(-2) + '/' + ('0' + months[$2].num).slice(-2) + '/' + $4;
                                break;
                        }

                        return res;
                    });
                },
                thousands: function (num) {
                    return numeral(num).format(0.0);
                },
                locale: function (data) {
                    var html = '';

                    if (data !== undefined && Array.isArray(data) && data.length > 0) {
                        var locales = new Object();

                        for (var i in data) {
                            var key = data[i];
                            locales[key] = res.locals.__(key);
                        }

                        localesData = 'var b=' + JSON.stringify(locales) + ';';

                        html += '<script type="text/javascript">';

                        html += 'function __(a) {' + localesData + 'return b[a];}';
                        html += '</script>';
                    }

                    return html;
                },
                urlVar: function (str) {
                    var re = /(%[a-z0-9._]+%)/gi;
                    var found = str.match(re);

                    if (found !=+ null) {
                        for (var i in found) {
                            var vars = found[i].replace(/[%]*/g, '');
                            str = str.replace(found[i], self.config('server.' + vars));
                        }
                    }

                    re = /([(].+[|][a-z_]+[)])/gi;
                    found = str.match(re);

                    if (found !== null) {
                        for (var i in found) {
                            var vars = found[i].replace(/[()]+/g, '').split('|');

                            if (vars[1] === 'url_encode') {
                                str = str.replace(found[i], encodeURIComponent(vars[0]));
                            }
                        }
                    }

                    return str;
                },
                url: {
                    base: function (uri, params) {
                        var uri = path.normalize('/' + uri);
                        var url = configs.url.base + uri;
                        return this.stringify(url, params);
                    },
                    assets: function (uri, params) {
                        var uri = path.normalize('/' + uri);
                        var url = configs.url.assets + uri;
                        return this.stringify(url, params);
                    },
                    stringify: function (url, params) {
                        return url + this.__getQueries(params);
                    },
                    __getQueries: function (params) {
                        var queries = '';

                        if (Object.keys(params).length > 0) {
                            queries = '?' + qs.stringify(params);
                        }

                        return queries;
                    }
                },
                assets: {
                    __device: 'mobile',
                    __type: 'css',
                    __module: undefined,
                    css: function (module) {
                        return this.__assets('css', module);
                    },
                    js: function (module) {
                        return this.__assets('js', module);
                    },
                    __assets: function (type, module) {
                        var device = 'desktop';

                        if (req.device.type !== 'desktop') {
                            device = 'mobile';
                        }

                        this.__device = device;
                        this.__type = type;
                        this.__module = module;
                        var assetsName = this.__getValidName();
                        var assets = this.__html(assetsName);
                        return assets;
                    },
                    __getValidName: function () {
                        var type = this.__type;
                        var name = this.__getName(this.__module || 'global');

                        name = name.replace(/[.][a-z]+$/gi, '');
                        var re = new RegExp(name, 'gi');

                        for (var i in configs.assets[type]) {
                            for (var __name in configs.assets[type][i]) {
                                if (__name.match(re)) {
                                    return __name;
                                }
                            }
                        }

                        return this.__getName('global');
                    },
                    __getName: function (module) {
                        return configs.app.assets_dir + '/min/' + this.__device + '.' + module + '.min.' + this.__type;
                    },
                    __html: function (name) {
                        var type = this.__type;
                        var data = configs.assets[type];
                        var html = '';

                        if (IS_DEV) {
                            for (var i in data) {
                                if (data[i][name] !== undefined) {
                                    if (IS_DEV) {
                                        for (var j in data[i][name]) {
                                            var filepath = data[i][name][j];
                                            html += this.__htmlTag(type, filepath);
                                        }
                                    } else {
                                        html = this.__htmlTag(type, name);
                                    }
                                }
                            }
                        } else {
                            html = this.__htmlTag(type, name);
                        }

                        return html;
                    },
                    __htmlTag: function (type, filepath) {
                        var html = '';
                        filepath = filepath.replace(configs.app.assets_dir, configs.url.assets);

                        switch (type) {
                            case 'css':
                                html = '<link href="' + filepath + '" type="text/css" rel="stylesheet">\n';
                                break;
                            case 'js':
                                html = '<script src="' + filepath + '" type="text/javascript"></script>\n';
                                break;
                        }

                        return html;
                    }
                }
            };

            if (next) return next();
        }
    };

    return {
        settings        : settings,
        set             : set,
        express         : express,
        router          : router,
        sysPath         : sysPath,
        appPath         : appPath,
        config          : config,
        import          : load,
        service         : service,
        handler         : handler,
        middleware      : middleware,
        config          : config,
        enforceMobile   : enforceMobile,
        locals          : locals
    }
})();
