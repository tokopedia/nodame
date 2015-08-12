# TODO: Make dynamic

Slack = require 'slack-client'

class Notification
  constructor: ->
    @NOTIFICATION = nodame.config('notification')
    @CLIENTS = @NOTIFICATION.clients
    return

  send: ->
    if @NOTIFICATION.enable
      if @CLIENTS.slack.enable
        token = @CLIENTS.slack.token
        channel_id = @CLIENTS.slack.channel_id

        return unless token? or channel_id?

        message = @CLIENTS.slack.message ? ''
        message = "\n\n#{message}" if message?
        title = @CLIENTS.slack.title ? nodame.config('app.name')
        url = @CLIENTS.slack.url ? nodame.config('url.base')
        auto_reconnect = true
        auto_mark = true
        slack = new Slack(token, auto_reconnect, auto_mark)

        slack.on 'open', ->
          groups = (group.name for id, group of slack.groups when group.is_open and not group.is_archived)
          channel = slack.getChannelGroupOrDMByID(channel_id)
          time = new Date()
          env = nodame.env()
          body = ">>>*[#{title} (#{env})]* _restarted_ \n_#{time}_\n#{url}#{message}"
          channel.send(body)
          slack.disconnect()
          console.log('Notification sent to slack.')

        slack.login()

    return

module.exports = Notification
