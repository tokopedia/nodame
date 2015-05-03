var path = require('path');
var swig = require('swig');

function views(app) {
    app.engine('html', swig.renderFile)
    app.set('views', APP_PATH + '/views');
    app.set('view engine', 'html');

    var swigLocals = {
        'currentYear': (new Date()).getFullYear(),
        'is_dev': IS_DEV,
        'menu': helper.config.get('menu')
        // 'processTime': function() {
        //     return '0.000000';
        // }
    };

    if(IS_DEV) {
        app.set('view cache', false);
        swig.setDefaults({
            varControls: ['{(', ')}'],
            locals: swigLocals,
            cache: false
        });
    }
    else {
        swig.setDefaults({
            locals: swigLocals
        });
    }

    swig.setFilter('push', filterPush);
    swig.setFilter('range', filterRange);
    swig.setFilter('even', filterEven);
}

function filterPush(arr, val) {
    arr.push(val);
    return arr; 
}

function filterRange(arr, start, end, step) {
    var range = [];
    var typeofStart = typeof start;
    var typeofEnd = typeof end;

    if (step === 0) {
        throw TypeError("Step cannot be zero.");
    }

    if (typeofStart == "undefined" || typeofEnd == "undefined") {
        throw TypeError("Must pass start and end arguments.");
    } 
    // else if (typeofStart != typeofEnd) {
    //     console.log(typeofStart);
    //     console.log(typeofEnd);
    //     throw TypeError("Start and end arguments must be of same type.");
    // }

    typeof step == "undefined" && (step = 1);

    if (end < start) {
        step = -step;
    }

    if (typeofStart == "number") {

        while (step > 0 ? end >= start : end <= start) {
            range.push(start);
            start += step;
        }

    } else if (typeofStart == "string") {

        if (start.length != 1 || end.length != 1) {
            throw TypeError("Only strings with one character are supported.");
        }

        start = start.charCodeAt(0);
        end = end.charCodeAt(0);

        while (step > 0 ? end >= start : end <= start) {
            range.push(String.fromCharCode(start));
            start += step;
        }

    } else {
        throw TypeError("Only string and number types are supported");
    }

    return range;

}

function filterEven(input){
    if(input % 2 == 0){
        return true;
    }
    else{
        return false;
    }
}

module.exports = views;
