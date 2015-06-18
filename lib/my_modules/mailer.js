var mandrill = nodame.import('mandrill-api/mandrill');

var mailer = (function () {
    var key         = nodame.config('email.mandrill_key');
    var client      = new mandrill.Mandrill(key);
    var body        = '';
    var bodyBaseDir = nodame.appPath() + '/views/emails/';

    var send        = function (toAddr, toName, subject, html) {
        var config  = nodame.config('email');
        var message = {
            'html'      : html,
            'subject'   : subject,
            'from_email': config.from_email,
            'from_name' : config.from_name,
            'to': [
                {
                    'email' : toAddr,
                    'name'  : toName,
                    'type'  : 'to'
                }
            ],
            'headers': {
                'Reply-To': config.from_email
            },
            'important': false,
            'bcc_address': config.bcc_email,
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
        var message = {
            'html'      : err,
            'subject'   : subject,
            'from_email': 'alert@tokopedia.com',
            'from_name' : 'Tokopedia Tiket Alert',
            'to': [
                {
                    'email' : 'doraemon@tokopedia.com',
                    'name'  : 'Doraemon',
                    'type'  : 'to'
                }
            ],
            'headers': {
                'Reply-To': 'alert@tokopedia.com'
            },
            'important': false,
            // 'bcc_address': config.bcc_addr,
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
