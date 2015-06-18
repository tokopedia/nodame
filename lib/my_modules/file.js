var sha512 = nodame.import('js-sha512').sha512;

exports.readJSON = function (filepath) {
    var fs = nodame.import('fs');

    if (!fs.statSync(filepath)) {
        return;
    }

    return JSON.parse(fs.readFileSync(filepath));
};

exports.readGRUNT = function (filepath) {
    var path        = nodame.import('./path');
    var json        = this.readTOML(filepath);
    var confDir     = path.dirname(filepath);
    var config      = this.readTOML(confDir + '/main.ini');
    var assetsDir   = config.app.assets_dir;
    var grunt       = new Object();

    var typeDir = {
        css: 'css',
        js: 'scripts'
    };

    for (var groups in json) {
        for (var group in json[groups]) {
            for (var type in json[groups][group]) {
                if (grunt[type] === undefined) {
                    grunt[type] = new Array();
                }

                var baseName    = assetsDir + '/min/' + groups + '.' + group;
                var hash        = __hash(baseName + type, 8);
                var dest        = baseName + '.min.' + hash  + '.' + type;
                var destSrc     = new Object();
                destSrc[dest]   = new Array();
                var baseDir     = assetsDir + '/' + typeDir[type] + '/';

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
                            var filepath = baseDir + json[groups][group][type][i];

                            destSrc[dest].push(filepath);
                        }
                    }
                }

                grunt[type].push(destSrc);
            }
        }
    }

    return grunt;
}

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
}

exports.readTOML = function (filepath) {
    var fs      = nodame.import('fs');
    var toml    = nodame.import('./toml-js');

    if (!fs.statSync(filepath)) {
        return;
    }

    return toml.parse(fs.readFileSync(filepath));
}