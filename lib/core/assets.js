var assetmanager = require('assetmanager');

function assets(app) {
    var configDir = CONFIG_DIR_PATH || __dirname _ + '/../../../config';
    return assetmanager.process({
            assets: require(configDir + '/assets.json'),
            debug: IS_DEV,
            webroot: 'public/kai'
        });
}

module.exports = assets;
