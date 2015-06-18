var npmPath = require('path');
var path    = npmPath;

path.view = function (req, module, file) {
    var device      = 'desktop';
    var template    = 'default';

    if (req && req.device.type == 'phone') {
        device = 'mobile';
    }

    if (TEMPLATE !== null) {
        template = TEMPLATE;
    }

    if (device == 'phone' && MOBILE_TEMPLATE !== null) {
        template = MOBILE_TEMPLATE;
    }

    return path.join(device, TEMPLATE, module, file);
}

module.exports = path;
