Numeral = require('numeral');

numeral = (app) ->
  app.use(init_numeral)

init_numeral = (req, res, next) ->
  Numeral.language 'id',
    delimiters:
      thousands: '.'
      decimal: ','
    abbreviations:
      thousand: 'rb'
      million: 'jt'
      billion: 'b'
      trillion: 't'
    ordinal: -> ''
    currency:
      symbol: 'Rp '

  Numeral.language('id')
  next()
  return

module.exports = numeral
