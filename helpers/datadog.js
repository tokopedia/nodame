var StatsD = require('node-dogstatsd').StatsD;
var parent = this;
var clientStatsD;

exports.getClient = function () {
    var configDatadog = helper.config.get('datadog');
    
    // console.log(configDatadog);

    if(!clientStatsD) {
        clientStatsD = new StatsD(configDatadog.host, configDatadog.port);
    }

    // clientStatsD.socket.on('error', function (exception) {
    //     console.log ("error event in socket.send(): " + exception);
    // });

    return clientStatsD;
}
