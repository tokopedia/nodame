Test = require('nodame/test')
StrConv = require('nodame/strconv')
StrConvTest = new Test('StrConv')

# Test btoi($1)
test = StrConvTest.set('btoi($1)', (args) -> StrConv.btoi(args))
test.should(true).return().equal(1)
test.should(false).return().equal(0)

tests = [1, 'a', [], {}]
test.many().should(tests, 'invalid input').return().undefined()
