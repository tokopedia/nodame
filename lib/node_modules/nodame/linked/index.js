exports.getLinked = function (data) {
    var result = new Object();

    if (data && data.links) {
        var links = data.links;

            for (var key in links) {
                var type    = links[key].type;
                var linked  = data.linked;

                if (linked[type] && !linked[type]['error']) {
                    result[type] = {};
                    linked[type].forEach(function (entry) {
                        result[type][entry.id] = entry;
                    });
                }
            }
    }

    return result;
};
