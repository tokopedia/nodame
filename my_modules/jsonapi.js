//data: result API
exports.parse = function (data) {
    var result = {};
    try {
        result = JSON.parse(data);
    } catch (e) {
        console.log(e);
    }
    return result;
};