###
# @author   Argi Karunia <arugikaru@yahoo.co.jp>
# @author   Rendy Halim <https://github.com/RendyHalim>
# @link     https://gihtub.com/tokopedia/Nodame
# @license  http://opensource.org/licenses/maintenance
#
# @version  1.2.2
###

measure = require('measure')
querystring = require('query-string')
DATADOG       = nodame.config('logger.clients.datadog')

`GET    = 'GET'`
`POST   = 'POST'`
`PUT    = 'PUT'`
`DELETE = 'DELETE'`
`UPDATE = 'UPDATE'`
`PATCH = 'PATCH'`

UA = 'curl/7.43.0'

class Request
  ###
  # @constructor
  # @param  string  url
  # @param  object  optional custom options
  # @throw On missing url args
  ###
  constructor: (url, opts) ->
    # Validate args
    throw new Error 'Missing url args' unless url?
    # Assign default options
    @__default_options(url)
    # Assign custom options if exists and is object
    @__custom_options(opts) if opts? and typeof opts is 'object'
    # Set client
    @__set_client()
    @__timeout = 5
    return
  ###
  # @method Parse URL and assign the results to options
  # @param  string  URL
  # @private
  # @throw  On unallowed protocol
  ###
  __parse_url: (url) ->
    # URL regex
    re = /^(?:((http[s]{0,1}):\/\/))?([a-z0-9-_\.]+)(?:(:[0-9]+))?(.*)$/
    found = url.match(re)
    # Set default as http when protocol is not found
    protocol = found[2] || 'http'
    # Validate protocol
    allowed_protocol = ['http', 'https']
    if allowed_protocol.indexOf(protocol) is -1
      throw new Error 'Unallowed protocol'
    # Set port
    if found?[4]?
      port = found[4]
    else
      port = if protocol is 'http' then '80' else '443'
    # Assign parsed_url object
    @__options =
      protocol: "#{protocol}:"
      host: found[3]
      port: port.replace(':', '')
      path: found[5]
      headers: {}
    return
  ###
  # @method Set default options
  # @param  string  URL
  # @private
  ###
  __default_options: (url) ->
    @__parse_url(url)
    @__options.headers['User-Agent'] = UA
    return
  ###
  # @method Set default options
  # @private
  ###
  __custom_options: (options) ->
    @set(option, options.option) for option of options
    return
  ###
  # @method Set request client
  # @private
  ###
  __set_client: ->
    @__client = require(@__options.protocol.replace(':', ''))
    return
  ###
  # @method Set option
  # @param  string  key
  # @param  object  value
  # @public
  ###
  set: (key, val) ->
    # Validate
    throw new Error 'Missing args' if not key? or not val?
    # Assign value
    @__options[key] = val
    return @
  ###
  # @method Set header
  # @param  string  key
  # @param  string  value
  # @public
  # @throw on missing args
  ###
  header: (key, args..., arg) ->
    # Validate
    throw new Error 'Missing header args' if not key? or not arg?
    # Normal header
    if args.length is 0
      val = arg
    # Anonymous function header
    else
      # Assign anonymous function
      fn = arg
      # Validate type
      throw new TypeError 'Invalid args type' unless typeof fn is 'function'
      # Get value from anonymous function
      val = fn(args...)
    # Assign value to header
    @__options.headers[key] = val
    return @
  ###
  # @method Assign metric name
  # @public
  # @param  string name
  # @throw  on undefined name
  ###
  metric: (name) ->
    # Validate existence of anonymous function
    throw new Error 'Missing name args' unless name?
    # Validate args type
    throw new TypeError 'Invalid type of name args' unless typeof name is 'string'
    # Assign metric
    @__metric = name
    return @
  ###
  # @method Set timeout
  # @public
  # @param  int second
  # @throw on args type is empty or not number
  ###
  timeout: (second) ->
    # Validate the existence of second args
    throw new Error 'Missing args' unless second?
    # Validate args type
    throw new TypeError 'Invalid args type' unless typeof second is 'number'
    # Assign timeout
    @__timeout = second
    return @
  ###
  # @method Assign content-type
  # @public
  # @param  string  type
  # @throw on empty type and invalid type
  ###
  type: (type) ->
    # Validate empty type
    throw new Error 'Missing args' unless type?
    # Validate type
    throw new TypeError 'Invalid args type' unless typeof type is 'string'
    # Assign type
    @__content_type = type
    return @
  ###
  # @method GET method
  # @public
  # @param  callback
  ###
  get: (callback) ->
    @__request(GET, callback)
    return
  ###
  # @method POST method
  # @public
  # @param  callback
  ###
  post: (callback) ->
    @__request(POST, callback)
    return
  ###
  # @method PUT method
  # @public
  # @param  callback
  ###
  put: (callback) ->
    @__request(PUT, callback)
    return
  ###
  # @method UPDATE method
  # @public
  # @param  callback
  ###
  update: (callback) ->
    @__request(UPDATE, callback)
    return
    ###
  # @method PATCH method
  # @public
  # @param  callback
  ###
  patch: (callback) ->
    @__request(PATCH, callback)
    return
  ###
  # @method DELETE method
  # @public
  # @param  callback
  ###
  delete: (callback) ->
    @__request(DELETE, callback)
    return
  ###
  # @method Set data
  # @private
  # @param  object  data
  # @param  string  type
  ###
  data: (data, type) ->
    # Validate data
    throw new Error 'Missing data args' unless data?
    # Assign default type
    type = 'json' if not @__content_type? and not type?
    # Set Content-Type
    switch type
      when 'form'
        @header('Content-Type', 'application/x-www-form-urlencoded')
        data = querystring.stringify(data)
      when 'json'
        @header('Content-Type', 'application/vnd.api+json')
        data = JSON.stringify(data)
      when 'xml'
        @header('Content-Type', 'application/xml')
        data = data
      else
        @header('Content-Type', type)
        data = data
    # Set data
    @set('body', data)
    # Set content length
    @header('Content-Length', data.length)
    return @
  ###
  # @method Execute request
  # @private
  # @param  string  method
  # @param  callback
  ###
  __request: (method, callback) ->
    @set('method', method)
    # Response handler
    response_handler = (res) =>
      # Measure httpRequest response time
      # Initialize data
      data = ''
      # Append chunked data
      res.on 'data', (chunk) =>
        data += String(chunk)
        return
      # Parse data
      res.on 'end', () =>
        # Log request stat
        # TODO: log is undefined
        if done? && @__metric?
          log.stat.histogram("#{DATADOG.app_name}.request.#{@__metric}", done(), ['env:' + nodame.env()])
        result = @__parse(res.headers['content-type'], data)
        return callback(null, result)
      return
    done = measure.measure(@__metric) if @__metric?
    # Execute request
    req = @__client.request(@__options, response_handler)
    # Error handler
    req.on 'error', (err) =>
      if @__metric?
        log.stat.increment("#{DATADOG.app_name}.request.#{@__metric}.failed", ['env:' + nodame.env()])

      error =
        id: '110102'
        title: 'Request timeout'
        detail: "Can't reach server at #{@__options.protocol}//#{@__options.host}:#{@__options.port}#{@__options.path}"

      unless req.socket.destroyed
        console.log { id: error.id, title: error.title, detail: error.detail }
        # TODO: log is undefined
        # log.alert(error.id, "#{error.title}. #{error.detail}")
      return
    # Write data
    write_methods = [POST, PUT, UPDATE, DELETE, 'PATCH']
    req.write(@__options.body) if write_methods.indexOf(@__options.method) isnt -1
    # Timeout handler
    req.setTimeout @__timeout * 1000, () =>
      if @__metric?
        log.stat.increment("#{DATADOG.app_name}.request.#{@__metric}.timeout", ['env:' + nodame.env()])
      error =
        id: '110102'
        title: 'Request timeout'
        detail: "Can't reach server at #{@__options.protocol}//#{@__options.host}:#{@__options.port}#{@__options.path} with data: #{@__options.body}"

      result =
        errors: [error]
      # Send alert
      console.log { id: error.id, title: error.title, detail: error.detail }
      # TODO: log is undefined
      # log.alert(error.id, sprintf('%s. %s', error.title, error.detail))
      # Destroy socket
      req.socket.destroy()
      # Abort socket
      req.abort()
      return callback(true, result)
    # Close request
    req.end()
    return
  ###
  # @method Parse response data
  # @private
  # @param  string  content-type
  # @param  object  data
  ###
  __parse: (content_type, data) ->
    # Validate content-type
    return data unless content_type?
    # Validate xml or html response
    if content_type?.match(/xml|html/)? and !(data[0] is '{' or data[0] is '[')
      return data
    # Parse JSON
    try
      result = JSON.parse(data)
    catch err
      error =
        id: '110101'
        title: 'Invalid response data'
        detail: "Failed in fetching data from #{@__options.protocol}//#{@__options.host}:#{@__options.port}#{@__options.path}.\n\nResponse Data:\n#{data}"
      result =
        errors: [error]
      console.log { id: error.id, title: error.title, detail: error.detail }
      # TODO: log is undefined
      # log.critical(error.id, "#{error.title}. #{error.detail}")
    return result

module.exports = Request
