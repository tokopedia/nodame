Test = require('nodame/test')
DateParser = require('nodame/date')
DateParserTest = new Test('DateParser')

# Test parseDate($1)
test = DateParserTest.set(
  'parseDate($1)'
  (args) -> DateParser.parseDate(args)
)
test.should('20-12-2020').return().equal(new Error 'Invalid Date')

# Test parseDate($1, 'dd-mm-yyyy')
test = DateParserTest.set(
  'parseDate($1)'
  (args) -> DateParser.parseDate(args, 'dd-mm-yyyy')
)
test.should('20-12-2020').return().equal(new Error 'Invalid Date')

test = DateParserTest.set(
  'getOptMonth()'
  (args) -> DateParser.getOptMonth()
)
opt_month = [
  {name: 'Jan', value: 1 }
  {name: 'Feb', value: 2 }
  {name: 'Mar', value: 3 }
  {name: 'Apr', value: 4 }
  {name: 'May', value: 5 }
  {name: 'Jun', value: 6 }
  {name: 'Jul', value: 7 }
  {name: 'Aug', value: 8 }
  {name: 'Sep', value: 9 }
  {name: 'Oct', value: 10 }
  {name: 'Nov', value: 11 }
  {name: 'Dec', value: 12 }
]
test.should().return().equal(opt_month)
