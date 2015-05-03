var assetmanager = require('assetmanager');
var path         = helper.load.util('path');

function assets(app) {
    return assetmanager.process({
            assets: require(APP_PATH + '/config/assets.json'),
            debug: IS_DEV,
            webroot: 'public/kai'
        });
}

module.exports = assets;
