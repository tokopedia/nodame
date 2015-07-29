argv = ->
  commander = require 'commander'
  # Set commands
  # TODO: config
  set: ->
    commander
      .usage '[options] <file ...>'
      .option '-c, --config <file>', 'Config file location'
      .option '-e, --env <env>', 'Application environment'
      .option '-S, --staging', 'Set staging environment'
      .option '-P, --production', 'Set production environment'
      .option '-p, --port <port>', 'Set port'
      .option '-t, --test', 'Run test'
      .option '-M, --maintenance', 'Run in maintenance mode'
      .parse process.argv
    commander
  # Get argv from command
  get: (key) ->
    commander[key]

module.exports = argv()
