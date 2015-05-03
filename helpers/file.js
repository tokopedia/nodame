var sha512 = require('js-sha512').sha512;

var file = function (environment) {
    var isDev = true;

    var init = function () {
        if (environment === undefined) {
            isDev = true;
            return;
        }

        isDev = environment !== 'production' && environment !== 'staging' ? true : false;
        return;
    };

    var readJSON = function (filepath) {
        var fs = require('fs');

        if (!fs.statSync(filepath)) {
            return;
        }

        return JSON.parse(fs.readFileSync(filepath));
    };

    var readGRUNT = function (filepath) {
        var path = require('./path');
        var json = this.readTOML(filepath);
        var confDir = isDev ? path.dirname(filepath) + '/../config-devel' :path.dirname(filepath);
        var filename = path.normalize(confDir + '/main.ini');
        var config = this.readTOML(filename);
        console.log(filename);
        var assetsDir = config.server.assets.dir;
        var grunt = new Object();

        var typeDir = {
            css: 'css',
            js: 'js'
        };

        for (var groups in json) {
            for (var group in json[groups]) {
                for (var type in json[groups][group]) {
                    if (grunt[type] === undefined) {
                        grunt[type] = new Array();
                    }

                    var baseName = assetsDir + '/min/' +
                        groups + '.' + group;
                    var hash = __hash(baseName + type, 8);
                    var dest = baseName + '.min.' + hash  + '.' + type;
                    var destSrc = new Object();
                    destSrc[dest] = new Array();
                    var baseDir = assetsDir + '/' +
                            typeDir[type] + '/';

                    if (group != 'global') {
                        var goFiles = json[groups]['global'][type];

                        for (var i in goFiles) {
                            destSrc[dest].push(baseDir + goFiles[i]);
                        }
                    }

                    if (json[groups][group][type].length > 0) {
                        for (var i in json[groups][group][type]) {
                            var filename = json[groups][group][type][i];

                            if (filename !== undefined) {
                                var filepath = baseDir +
                                    json[groups][group][type][i];

                                destSrc[dest].push(filepath);
                            }
                        }
                    }

                    grunt[type].push(destSrc);
                }
            }
        }

        return grunt;
    };

    var __hash = function (str, length) {
        var hash = sha512(str + new Date());

        if (length !== undefined && length < hash.length) {
            var start = 0;

            if (length < Math.floor(hash.length / 2)) {
                start = Math.floor(hash.length / 2) - Math.floor(length / 2);
            }

            hash = hash.substr(start, length);
        }

        return hash;
    };

    var readTOML = function (filepath) {
        var fs = require('fs');
        var toml = require('./toml-js');

        if (!fs.statSync(filepath)) {
            return;
        }

        return toml.parse(fs.readFileSync(filepath));
    };

    init();

    return {
        readJSON: readJSON,
        readGRUNT: readGRUNT,
        readTOML: readTOML
    }
};

module.exports = file;