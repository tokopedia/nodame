Router      = nodame.router()
HTML        = nodame.require('nodame/html')
About       = nodame.require('service/about')

render_about = (req, res, next) ->
  contact = About.contact()
  html = HTML.new(req, res)

  html.stash.set('contact', contact)
  html.render
    module: 'about'
    file: 'index'

Router.get('/', render_about)

module.exports = Router
