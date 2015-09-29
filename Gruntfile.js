var file    = require(__dirname + '/lib/file');
var path    = require(__dirname + '/lib/path');
var fs      = require('fs');

module.exports = function (grunt) {
    // Project Configuration
    process.stdout.write('Reading config ... ');

    var configPath  = path.safe(path.app + '/configs');
    var config      = file.readGRUNT(configPath + '/assets.yaml');

    process.stdout.write('Done\n\n');

    var filename    = configPath + '/.assets';
    var confWrite   = copyConfig(config);
    var jsonConfig  = JSON.stringify(config);

    process.stdout.write('Writing production assets configuration ... ');
    var err = fs.writeFileSync(filename, jsonConfig);

    if (err !== undefined) {
        process.stdout.write('Failed\n\n');
        return;
    } else {
        process.stdout.write('Done\n');
    }

    grunt.initConfig({
        default: {

        },
        cssmin: {
            main: {
            files: confWrite.css
            }
        },
        uglify: {
            page: {
                options: {
                    mangle: true,
                    compress: true
                },
                files: confWrite.js
            }
        }
    });

    //Load NPM tasks
    grunt.loadNpmTasks('grunt-contrib-cssmin');
    grunt.loadNpmTasks('grunt-contrib-uglify');

    //Making grunt default to force in order not to break the project.
    grunt.option('force', true);

    //Default task(s).
    grunt.registerTask('default', ['cssmin', 'uglify']);
};

var rename = function (filepath, min) {
    var name;
    var typeDir = path.extname(filepath).substr(1);

    if (min) {
        var re = /^.+[/]/;
        name = path.safe(path.app + '/assets/min/' + filepath.replace(re, ''));
    } else {
        name = path.safe(path.app + '/assets/' + typeDir + '/' + filepath);
    }

    return name;
};

var copyConfig = function (config) {
    var tmp = {};

    for (var type in config) {
        tmp[type] = [];
        for (var typeIdx in config[type]) {
            for (var key in config[type][typeIdx]) {
                var _tmp = {};
                var _key = rename(key, true);
                _tmp[_key] = [];

                for (var keyFile in config[type][typeIdx][key]) {
                    var _file = config[type][typeIdx][key][keyFile];
                    _file = rename(_file, false);
                    _tmp[_key].push(_file);
                }

                tmp[type].push(_tmp);
            }
        }
    }

    return tmp;
};
