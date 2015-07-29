Assert  = require('assert')
md5     = require('md5')
# colors  = require('colors')
# String::repeat = (n) -> Array(n + 1).join(this)

REMAIN    = '__REMAIN__'
NOT_USED  = '__NOT_USED__'
ORIGINAL_VALUE = '__ORIGINAL_VALUE__'

class Test
  constructor: (title) ->
    # title_ln = 61
    # group_title = "TASK: [#{title}]"
    # repeat_ln = title_ln - (group_title.length + 1)
    # console.log "#{group_title.cyan} #{'*'.repeat(repeat_ln).cyan}"
    @title = title
    return

  set: (name, argv...) ->
    condition = undefined
    callback  = undefined

    if argv?
      if argv.length is 1
        if typeof argv[0] is 'string'
          condition = argv[0]
        if typeof argv[0] is 'function'
          callback  = argv[0]
      if argv.length is 2
        if typeof argv[0] is 'string' and typeof argv[1] is 'function'
          condition = argv[0]
          callback  = argv[1]
    return new Task(@title, name, condition, callback)

  not: (str) -> "not #{str}"

class Task
  constructor: (group, name, condition, callback) ->
    throw new Error 'Test group not set.' unless group?
    throw new Error 'Test task name not set.' unless name?
    @_group = group
    @_name = name
    @_condition = condition
    @_callback = callback

    @EQUAL  = 1
    @TRUE   = 2
    @FALSE  = 3

    return

  group: (arg) ->
    @_group = arg
    return

  name: (arg) ->
    @_name = arg
    return

  condition: (arg) ->
    @_condition = arg
    return

  callback: (arg) ->
    @_callback = arg
    return

  assert: (args, expected, assertion = @EQUAL, condition) ->
    condition = condition ? @_condition

    unless condition?
      switch assertion
        when @TRUE  then condition = 'true'
        when @FALSE then condition = 'false'
        else condition = 'equal'

    condition = "should #{condition}"
    actual = @actual(args)

    describe @_group, =>
      describe @_name, =>
        it condition, =>
          switch assertion
            when @EQUAL, @TRUE, @FALSE
              Assert.deepEqual(actual, expected)
    return

  actual: (args) ->
    if @_callback?
      if args?
        actual = @_callback(args)
      else
        actual = @_callback()
    else
      actual = args

    return actual

  assertEqual: (args, expected, condition) ->
    @assert(args, expected, @EQUAL, condition)
    return

  assertTrue: (args, condition) ->
    @assert(args, true, @TRUE, condition)
    return

  assertFalse: (args, condition) ->
    @assert(args, false, @FALSE, condition)
    return

  many: ->
    @_many = true
    return @

  should: (arg, condition) ->
    many = @_many ? false
    # reset @_many to false
    @_many = false
    return new Should(@_group, @_name, arg, many, condition, @_callback)

class Should extends Task
  __many: false
  __condition: undefined

  constructor: (group, name, args, many, condition, callback) ->
    @__many = many
    @__condition = condition
    throw new Error 'Test group not set.' unless group?
    throw new Error 'Test task name not set.' unless name?
    # throw new Error 'Test task arg not set.' unless arg?
    @group(group)
    @name(name)
    @callback(callback)

    if args?
      @arg = args
      unless @__many
        @_arg_msg = @arg_msg(args)
      else
        for i of args
          @arg[i].msg = @arg_msg(args[i].args)

    return @

  arg_msg: (arg) ->
    _arg_msg = arg

    if typeof arg is 'object'
      if Object.prototype.toString.call(arg) is '[object Array]'
        if arg.length is 0
          _arg_msg = '[]'
      else
        if Object.keys(arg).length is 0
          _arg_msg = '{}'
    return _arg_msg

  return: ->
    @_return = true
    return @

  action: ->
    if @_return? and @_return
      return 'return'
    return ''

  equal: (arg) ->
    @expected = arg

    if @__many and !arg?
      @expected = NOT_USED

    @done()
    return

  undefined: ->
    @expected = undefined

    if @__many and !arg?
      @expected = NOT_USED
      
    @done()
    return

  set_many_default_args: (args) ->
    for i of @arg
      tmp = @arg[i]
      @arg[i] =
        args: tmp
        expected: unless args is REMAIN then args else tmp
    return

  remain: ->
    @expected = @arg

    if @__many
      @set_many_default_args(REMAIN)
      @expected = NOT_USED

    @done(ORIGINAL_VALUE)
    return

  true: ->
    @expected = true

    if @__many
      @set_many_default_args(true)
      @expected = NOT_USED

    @done()
    return

  false: ->
    @expected = false

    if @__many
      @set_many_default_args(false)
      @expected = NOT_USED

    @done()
    return

  done: (msg) ->
    msg = msg ? @expected

    if msg is NOT_USED or msg is ORIGINAL_VALUE
      switch msg
        when NOT_USED       then msg = 'correctly'
        when ORIGINAL_VALUE then msg = 'original value'
      msg = "#{@action()} #{msg}"
    else
      msg = "#{@action()} '#{msg}'"

    if @arg? and !@__many
      msg = "#{msg} on '#{@_arg_msg}'"
    if @__many and @__condition?
      msg = "#{msg} on #{@__condition}"

    many = @__many
    # reset many
    @__many = false
    @__condition = undefined

    # assign args to array if not many
    unless many
      args = [
        { args: @arg, expected: @expected }
      ]
    else
      args = @arg

    for arg in args
      @assertEqual(arg.args, arg.expected, msg)

    return

  not: (str) -> "not #{str}"

module.exports = Test
