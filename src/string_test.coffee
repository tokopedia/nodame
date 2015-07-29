lib     = "#{__dirname}/../lib"
Test    = require("#{lib}/test")
Strings = require("#{lib}/string")
StringsTest = new Test('Strings')

fn = ->

# Test trim()
test = StringsTest.set('trim($1)', (args) -> Strings.trim(args))
tests = [
  { args: ' foo ',                      expected: ' foo ' }
  { args: 'foo  bar  ',                 expected: 'foo bar ' }
  { args: '  foo  bar  ',               expected: ' foo bar ' }
  { args: [' foo  ', 'bar  '],          expected: [' foo ', 'bar ']}
  { args: { x: ' foo  ', y: 'bar  ' },  expected: { x: ' foo ', y: 'bar ' } }
]
test.many().should(tests).return().equal()
tests = [true, false, fn]
test.many().should(tests, 'invalid input').return().remain()

# Test trim()
test = StringsTest.set('trim($1, true)', (args) -> Strings.trim(args, true))
test.should(' foo ').return().equal('foo')
test.should('foo  bar ').return().equal('foo bar')
test.should('  foo  bar  ').return().equal('foo bar')
test.should([' foo  ', 'bar  ']).return().equal(['foo', 'bar'])
test.should({x: ' foo  ', y: 'bar  '}).return().equal({x: 'foo', y: 'bar'})
test.should(true).return().remain()
test.should(false).return().remain()
test.should(fn).return().remain()
