var validate = require("validate.js");

exports.__trim = function (str, middle) {
    if(middle) {
        re = /[ ]+/g;
        str = str.replace(re, ' ');
    }
    re = /^[ ]+|[ ]+$/g;
    str = str.replace(re, '');
    return str
}

exports.trim = function (data, middle) {
    if(validate.isObject(data)) {
        if(validate.isArray(data)) {
            var temp = [];
            for (var key in data) {
                if (data.hasOwnProperty(key)) {
                    if(validate.isString(data[key])) {
                        temp.push(this.__trim(data[key], middle));
                    } else {
                        temp.push(data[key]);
                    }
                }
            }
            return temp;
        } else {
            var temp = {};
            for (var key in data) {
                if (data.hasOwnProperty(key)) {
                    if(validate.isString(data[key])) {
                        temp[key] = this.__trim(data[key], middle);
                    } else {
                        temp[key] = data[key];
                    }
                }
            }
            return temp;
        }
    } else {
        if(validate.isString(data)) {
            return this.__trim(data, middle);
        }
    }
    return data;
};





