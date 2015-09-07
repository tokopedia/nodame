measure = require('measure')
querystring = require('query-string')

class Request

  GET = 'GET'
  POST = 'POST'
  PUT = 'PUT'
  DELETE = 'DELETE'
  __request = ''
  __options = ''
  request = 
    http: require('http')
    https: require('https')
  timeout = 5
  protocol = 'http'
  __metricName = ''
  
  constructor: (@url, @custom_options) ->
    options = this.getOptions(@url)
    for option of @custom_options
      options[option] = @custom_options[option]
    protocol = options.protocol
    __request = request[protocol]
    delete options.protocol
    __options = options
    return Request
    
  parseUrl: (url) ->
    re = /^(?:((http[s]{0,1}):\/\/))?([a-z0-9-_\.]+)(?:(:[0-9]+))?(.*)$/
    found = url.match(re)
    protocol = found[2] || 'http'
    
    if found?[4]?
      port = found[4]
    else
      if protocol == 'http'
        port = ':80'
      else
        port = ':443'
        
    parsedUrl =
      protocol: protocol
      host: found[3]
      port: (port).replace(':', '')
      path: found[5]
    return parsedUrl
      
  getOptions: (url) ->
    parsedUrl = this.parseUrl(url)  
    
    options = 
      protocol: parsedUrl.protocol
      host: parsedUrl.host
      port: parsedUrl.port
      path: parsedUrl.path
      headers:
        'User-Agent': 'curl/7.43.0'
        
    return options
      
  @header = (key, val) ->
    if __options?.header?[key]?
      delete __options.headers[key]
    
    __options.headers[key] = val
    return
      
  @simple_auth = (args, fn) ->
    auth = fn(args)
    if auth?
      if __options?.headers?['Authorization']?
        delete __options.headers['Authorization']
      __options.headers['Authorization'] = auth
    return
    
  @set_metricname = (key, metricName) ->
    if metricName?
      __metricName = key + metricName
    return
        
  parse = (contentType, data) ->
    unless contentType?
      return data
   
    if contentType?.match(/xml|html/)? && data.substr(0,1) != '{'
      return data
      
    try
      result = JSON.parse(data)
    catch err
      error = 
        id: '110101'
        title: 'Invalid response data'
        detail: sprintf('Failed in fetching data from %s://%s:%s%s.\n\nResponse Data:\n%s', protocol, __options.host, String(__options.port), __options.path, data)
      result = 
        errors: [error]
      log.critical(error.id, sprintf('%s. %s', error.title, error.detail));
      
    return result
      
  @setTimeout = (second) ->
    timeout = second
    return this
      
  @get = (callback) ->
    run(GET, '', (result) ->
      callback(result)
      return
    )
    return
      
  @post = (type, data, callback) ->
    __post(POST, type, data, (result) ->
      callback(result)
      return
    )
    return
    
  @put = (type, data, callback) ->
    __post(PUT, type, data, (result) ->
      callback(result)
      return
    )
    return
      
  @del = (type, data, callback) ->
    __post(DELETE, type, data, (result) ->
      callback(result)
      return
    )
    return
    
  __post = (method, type, data, callback) ->
    __data = 
      type: type
    
    switch type
      when 'form'
        header('Content-Type', 'application/x-www-form-urlencoded')
        __data.body = querystring.stringify(data)
      when 'json'
        header('Content-Type', 'application/vnd.api+json')
        __data.body = JSON.stringify(data)
      when 'xml'
        header('Content-Type', 'application/xml')
        __data.body = data
      else
        header('Content-Type', type)
        __data.body = data
        
    run method, __data, (result) ->
      callback(result)
      return
    return
    
  @set = (key, value) ->
    __options[key] = value
    return
       
  rebuild = (method, data) ->
    options = __options
    options.method = method
    if data != '' && data?
      options.body = data.body
      options.headers['Content-Length'] = data.body.length
    return options
      
  run = (method, data, callback) ->
    options = rebuild(method, data)
    req = __request.request(options, (res) ->
      if(__metricName?)
        done = measure.measure('httpRequest')
      
      __data = ''
      
      res.on('data', (chunk) ->
        __data += String(chunk)
        return
      )
      
      res.on('end', () ->
        if done?
          log.stat.histogram(__metricName, done(), ['env:' + nodame.env()])
        callback(parse(res.headers['content-type'], __data))
        return
      )
      
      return
    )
    
    req.on('error', (err) ->
      error =
        id: '110102'
        title: 'Request timeout'
        detail: sprintf('Can\'t reach server at %s://%s:%s%s', protocol, options.host, String(options.port), options.path)
      
      result = 
        errors: [error]
        
      unless req.socket.destroyed
        log.alert(error.id, sprintf('%s. %s', error.title, error.detail))
        
      return
    )
    
    if (method == POST || method ==  DELETE || method == PUT)
      req.write(options.body)
      
    req.setTimeout(timeout * 1000, () ->
      error = 
        id: '110102'
        title: 'Request timeout'
        detail: sprintf('Can\'t reach server at %s://%s:%s%s with data: %s', protocol, options.host, String(options.port), options.path, options.body)
      
      result =
        errors: [error]
      
      log.alert(error.id, sprintf('%s. %s', error.title, error.detail))
      req.socket.destroy()
      req.abort()
      callback(result)
      return
    )
    
    req.end()
    
module.exports = Request