var sha384 = require('js-sha512').sha384;

exports.getHash = function (type, id) {
    var secretKey = helper.config.get('secret_key');
    return sha384(secretKey[type] + '##' + id);
}