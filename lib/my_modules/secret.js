var sha384 = nodame.import('js-sha512').sha384;

exports.getHash = function (type, id) {
    var secretKey = nodame.config('secret_key');
    return sha384(secretKey[type] + '##' + id);
}
