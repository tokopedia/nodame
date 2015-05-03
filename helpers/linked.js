//data: result API
exports.getLinked = function (data) {
    // console.log(data);
    var result = new Object();

    if(data && data.links) {
        var links = data.links;

        // if (Object.keys(links).length > 0) {
            for (var key in links) {
                // console.log("key_links");
                // console.log(links[key]);

                var type = links[key].type;
                var linked = data.linked;

                // console.log('linked');
                // console.log(linked);

                if(linked[type] && !linked[type]['error']) {
                    result[type] = {};
                    linked[type].forEach(function(entry) {
                        result[type][entry.id] = entry;
                    });
                }
            }
        // }
    }

    // console.log("getLinked");
    // console.log(result);
    return result;
};