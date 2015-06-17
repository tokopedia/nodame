//dateTtime: 201502190800
exports.parseDate = function (dateTime, format) {
    var result;
    if(dateTime) {
        var dt = dateTime;

        if(format == 'dd-mm-yyyy') {
            var temp = [];
            temp = dt.split('-');
            dt = temp[2] + temp[1] + temp[0];
        }

        result = new Date(dt.substring(0, 4), (dt.substring(4, 6) - 1), dt.substring(6, 8), dt.substring(8, 10), dt.substring(10, 12));

        if(result == 'Invalid Date') {
            return false;
        }
    }

    return result;
};


exports.parseString = function (dateTime) {
    if (dateTime instanceof Date) {
        return dateTime.getFullYear() + ("0" + (dateTime.getMonth() + 1)).slice(-2) + ("0" + dateTime.getDate()).slice(-2);
    } else {
        return false;
    }
};

/**/
exports.calculateAge = function (birthday) {
    // console.log(birthday);
    var ageDifMs = Date.now() - birthday.getTime();
    if(ageDifMs < 0) {
        return -1;
    }
    var ageDate = new Date(ageDifMs); // miliseconds from epoch
    return Math.abs(ageDate.getUTCFullYear() - 1970);

    // var today = new Date();
    // var age = today.getFullYear() - birthDate.getFullYear();
    // var m = today.getMonth() - birthDate.getMonth();
    // if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) {
    //     age--;
    // }
    // return age;
}

exports.getOptDate = function () {
    var opt = [];

    for(var i = 1; i <= 31; i++){
        opt.push(i);
    }

    return opt;
}

exports.getOptMonth = function () {
    var opt = [];

    opt.push({
        name: 'Jan',
        value: 1
    });
    opt.push({
        name: 'Feb',
        value: 2
    });
    opt.push({
        name: 'Mar',
        value: 3
    });
    opt.push({
        name: 'Apr',
        value: 4
    });
    opt.push({
        name: 'May',
        value: 5
    });
    opt.push({
        name: 'Jun',
        value: 6
    });
    opt.push({
        name: 'Jul',
        value: 7
    });
    opt.push({
        name: 'Aug',
        value: 8
    });
    opt.push({
        name: 'Sep',
        value: 9
    });
    opt.push({
        name: 'Oct',
        value: 10
    });
    opt.push({
        name: 'Nov',
        value: 11
    });
    opt.push({
        name: 'Dec',
        value: 12
    });

    return opt;
}

exports.getOptYear = function (totalYear, start) {
    var opt = [];
    var currentYear = new Date().getFullYear();

    if(start == undefined) {
        start = 0;
    }

    var endYear     = currentYear + (start);
    var startYear   = endYear - totalYear;

    for(var i = startYear; i <= endYear; i++){
        opt.push(i);
    }
    // console.log(opt);
    return opt;
}

