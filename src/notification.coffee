# TODO: Make dynamic

Slack = require 'slack-client'

class Notification
  constructor: ->
    @NOTIFICATION = nodame.config('notification')
    @CLIENTS = @NOTIFICATION.clients

    if @NOTIFICATION.enable
      if @CLIENTS.slack.enable
        @token = @CLIENTS.slack.token
        @channel_id = @CLIENTS.slack.channel_id
        return unless @token? or @channel_id?
        auto_reconnect = @CLIENTS.slack.auto_reconnect
        auto_mark = @CLIENTS.slack.auto_mark
        @slack = new Slack(@token, auto_reconnect, auto_mark)
        @slack.login()
    return

  send: (title = 'notification', message = '') ->
    if @NOTIFICATION.enable
      if @CLIENTS.slack.enable
        message = "\n\n#{message}" if message?
        name = @CLIENTS.slack.name ? nodame.config('app.name')
        url = @CLIENTS.slack.url ? nodame.config('url.base')
        title = 'notification' unless title?
        channel_id = @channel_id

        @slack.on 'open', ->
          groups = (group.name for id, group of @groups when group.is_open and not group.is_archived)
          channel = @getChannelGroupOrDMByID(channel_id)
          time = new Date()
          env = nodame.env()
          body = ">>>*[#{name} (#{env})]* _#{title}_ \n_#{time}_\n#{url}#{message}"
          channel.send(body)
          # @slack.disconnect()
          console.log('Notification sent to slack.')



    return

module.exports = Notification
