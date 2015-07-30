Router      = nodame.router()
HTML        = nodame.require('nodame/html')
Home        = nodame.require('service/home')

render_home = (req, res, next) ->
  greets = Home.hello('World')
  html = HTML.new(req, res)

  html.stash.set('greets', greets)
  html.render
    module: 'home'
    file: 'index'

Router.get('/', render_home)

module.exports = Router
