'use strict';
var file = require('./nodame/helpers/file')('production');
var fs = require('fs');
var path = require('path');

module.exports = function (grunt) {
    // Project Configuration
    process.stdout.write('Reading config ... ');

    var config_path = path.normalize(__dirname + '/src/config');
    var config = file.readGRUNT(config_path + '/assets.ini');
    
    process.stdout.write('Done\n\n');
    
    var filename = config_path + '/.assets';
    var confWrite = copyConfig(config, 'write');
    var jsonConfig = JSON.stringify(config);

    process.stdout.write('Writing production assets configuration to src/config/.assets ... ');
    var err = fs.writeFileSync(filename, jsonConfig);

    if (err !== undefined) {
        process.stdout.write('Failed\n\n');
        return;
    } else {
        process.stdout.write('Done\n');
    }

    grunt.initConfig({
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

var rename = function (filepath, type) {
    var name;

    if (type === 'write') {
        name = 'src/' + filepath;
    } else {
        var re = /^.+[/]/;
        name = 'min/' + filepath.replace(re, '');
    }

    return name;
};

var copyConfig = function (config, confType) {
    var tmp = new Object();

    for (var type in config) {
        tmp[type] = new Array();
        for (var typeIdx in config[type]) {
            for (var key in config[type][typeIdx]) {
                var _tmp = new Object();
                var _key = rename(key, confType);
                _tmp[_key] = new Array();
                
                for (var keyFile in config[type][typeIdx][key]) {
                    var _file = config[type][typeIdx][key][keyFile];
                    _file = rename(_file, confType);
                    _tmp[_key].push(_file);
                }

                tmp[type].push(_tmp);
            }
        }
    }

    return tmp;
};