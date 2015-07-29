var mandrill = require('mandrill-api/mandrill');
var path     = require('nodame/path');

var mailer = (function () {
    // TODO: make flexible
    var key         = nodame.config('email.clients.mandrill.key');
    var client      = new mandrill.Mandrill(key);
    var body        = '';
    var bodyBaseDir = path.safe('views/emails/');

    var send        = function (toAddr, toName, subject, html) {
        var config  = nodame.config('email');
        var message = {
            'html'      : html,
            'subject'   : subject,
            'from_email': config.sender_addr,
            'from_name' : config.sender_name,
            'to': [
                {
                    'email' : toAddr,
                    'name'  : toName,
                    'type'  : 'to'
                }
            ],
            'headers': {
                'Reply-To': config.sender_addr
            },
            'important': false,
            'bcc_address': config.bcc_addr,
            'track_opens': true,
            'track_clicks': true,
            'auto_text': true
        };

        client.messages.send({
            'message': message,
            'async': false,
            'ip_pool': 'Main Pool',
            'send_at': '2015-01-01 00:00:00'
        }, function (result) {
            console.log(result);
        }, function (e) {
            var __message = 'A mandrill error occurred: ' + e.name + ' - ' + e.message;
            log.alert(__message);
            console.log(__message);
        });
    };

    var alert = function (subject, err) {
        var loggerCfg   = nodame.config('logger.clients.email');
        var message     = {
            'html'      : err,
            'subject'   : subject,
            'from_email': loggerCfg.sender_addr,
            'from_name' : loggerCfg.sender_name,
            'to': [
                {
                    'email' : loggerCfg.recipient_addr,
                    'name'  : loggerCfg.recipient_name,
                    'type'  : 'to'
                }
            ],
            'headers': {
                'Reply-To': loggerCfg.sender_addr
            },
            'important': false,
            'track_opens': true,
            'track_clicks': true,
            'auto_text': true
        };

        client.messages.send({
            'message': message,
            'async': false,
            'ip_pool': 'Main Pool',
            'send_at': '2015-01-01 00:00:00'
        }, function (result) {
            console.log(result);
        }, function (e) {
            console.log('A mandrill error occurred: ' + e.name + ' - ' + e.message);
        });
    };

    return {
        send: send,
        alert: alert
    }
})();

module.exports = mailer;
