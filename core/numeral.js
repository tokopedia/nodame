var Numeral = require('numeral');

function numeral(app) {
    app.use(function(req, res, next) {
        Numeral.language('id', {
            delimiters: {
                thousands: '.',
                decimal: ','
            },
            abbreviations: {
                thousand: 'rb',
                million: 'jt',
                billion: 'b',
                trillion: 't'
            },
            ordinal: function () {
                return ''; 
            },
            currency: {
                symbol: 'Rp '
            }
        });

        Numeral.language('id');

        next();
    });
}

module.exports = numeral;
