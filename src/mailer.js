var nodemailer   = require('nodemailer');
var smtpTransport= require('nodemailer-smtp-transport');
var EMAIL  = nodame.config('email');
var LOGGER = nodame.config('logger.clients.email');

var transporter  = nodemailer.createTransport(smtpTransport({
  host: "mail.tokopedia.local",
  port: 587,
  ignoreTLS: true
}));

var mailer = (function() {
  var opt = {};
  var options = {};

  var send = function(to, name, subject, html) {
    __send_mail(to, name, subject, html);
  };

  var alert = function(subject, html) {
    var to = LOGGER.recipient_addr;
    var name = LOGGER.recipient_name;
    __send_mail(to, name, subject, html);
  };

  var __send_mail = function(to, name, subject, html) {
    options = {
      from: EMAIL.sender_name + ' <' + EMAIL.sender_addr + '>',
      to: name + ' <' + to + '>',
      subject: subject,
      html: html,
      bcc: EMAIL.bcc_addr
    };

    transporter.sendMail(options, __send_mail_func);
  }

  var __send_mail_func = function(error, info) {
    if (error) {
      return console.log(error);
    }

    console.log("Message sent", info.response);
  };

  return {
    send: send,
    alert: alert
  }
})();

module.exports = mailer;
