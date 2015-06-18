var StatsD = nodame.import('node-dogstatsd').StatsD;
var parent = this;
var clientStatsD;

exports.getClient = function () {
    var configDatadog = nodame.config('datadog');

    if (!clientStatsD) {
        clientStatsD = new StatsD(configDatadog.host, configDatadog.port);
    }

    return clientStatsD;
}