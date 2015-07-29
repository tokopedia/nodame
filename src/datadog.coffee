StatsD = require('node-dogstatsd').StatsD

datadog = do ->
  @client = ->
    config = nodame.config('logger.clients.datadog')
    new StatsD(config.host, config.port) if config.host and config.port

  getClient: @client

module.exports = datadog
