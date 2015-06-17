var v   = require('validate.js');

v.isDefinedAll = function () {
    if (arguments.length > 0) {
        for (var i in arguments) {
            if (!v.isDefined(arguments[i])) {
                return false;
            }
        }

        return true;
    }

    return false;
};

v.isEmptyValue = function (obj, value) {
    if (v.isEmpty(obj)) {
        return value;
    }

    return obj;
};

v.isMatch = function (value, regex) {
    var found = value.match(regex);

    return !v.isEmpty(found);
}

module.exports = v;
