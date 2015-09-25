###
# @author   Argi Karunia <arugikaru@yahoo.co.jp>
# @author   Originally by Teddy Hong <teddy.hong11@gmail.com>
# @link     https://github.com/tokopedia/Nodame
# @license  http://opensource.org/licenses/MIT
#
# @version  1.2.0
###

Path        = require('./path')

APP         = nodame.config('app')
VIEW        = nodame.config('view')

class Render
  ###
  # @constructor
  ###
  constructor: (@req, @res) ->
    # Local variables
    @__locals = {}
    # Locales variable
    @__locals.locales = []
    # Set default page title
    @set('page_title', APP.title)
    # Set default file name
    @__file = 'index'
    return
  ###
  # @method Set local variable
  # @public
  # @param  string  key
  # @param  object  value
  ###
  set: (key, val) ->
    @__locals[key] = val
    return @
  ###
  # @method Set local variable
  # @public
  # @param  string  page title
  # @param  int     page number
  ###
  title: (title, page_num) ->
    separator     = APP.title_separator
    # TODO: change with i18n
    page_text     = 'Halaman'
    # Add separator
    title = "#{title} #{separator} #{default_title}"
    # Add page number if page exists
    title = "#{title}, #{page_text} #{page_num}" if page_num?
    # Assign title
    return @set('page_title', title)
  ###
  # @method Set menu
  # @public
  # @param  string  active menu
  ###
  menu: (active_menu) ->
    # Validate empty val
    throw new Error 'Missing active_menu args' unless active_menu?
    # Assign val
    return @set('menu', { active: active_menu })
  ###
  # @method Set assets name
  # @public
  # @param  string  assets name
  ###
  assets: (assets_name) ->
    # Validate empty val
    throw new Error 'Missing assets_name args' unless assets_name?
    # Assign val
    return @set('assets_name', assets_name)
  ###
  # @method Set locale
  # @public
  # @param  string  locale
  ###
  locale: (name) ->
    # Validate empty val
    throw new Erorr 'Missing locale args' unless name?
    # Validate value
    @__locals.locales.push(name) if @__locals.locales.indexOf(name) is -1
    return @
  ###
  # @method Set locales
  # @public
  # @param  object  locales
  ###
  locales: (locales) ->
    # Validate empty val
    throw new Erorr 'Missing locales args' unless locales?
    # Check if is array
    if typeof locales is 'object'
      @locale(name) for name in locales
    else
      @locale(locales)
    return @
  ###
  # @method Set module name
  # @public
  # @param  string  method name
  ###
  module: (@__module) ->
    # Validate empty val
    throw new Error 'Missing module args' unless @__module?
    return @
  ###
  # @method Set file name
  # @public
  # @param  string  file name
  ###
  file: (@__file) ->
    # Validate empty val
    throw new Error 'Missing file args' unless @__file?
    return @
  ###
  # @method Set view path
  # @public
  # @param  string  path
  ###
  view: (path) ->
    # Validate empty val
    throw new Error 'Missing path args' unless path?
    # Assign variables
    default_template  = VIEW.default_template
    template          = VIEW.template
    device            = VIEW.default_device
    adaptive          = VIEW.adaptive
    # Set 'phone' as 'mobile'
    # TODO: Set to switchable
    if @req.device?.type? and @req.device.type is 'phone' and adaptive
      device = 'mobile'
    # Set template to default when empty
    template = default_template unless template?
    # Set module and file
    paths       = path.split('/')
    module_name = paths[0]
    file_name   = paths[1] || 'index'
    # Get view path
    @__view_path = Path.join(device, template, module_name, file_name)
    return @
  ###
  # @method write response
  # @public
  ###
  send: (callback) ->
    # Set view path
    throw new Error 'View path is undefined' unless @__view_path?
    # Return callback if exists
    return @res.render(@__view_path, @__locals, callback)


module.exports = Render
