###
# @author  Argi Karunia <https://github.com/hkyo89>
# @link    https://github.com/tokopedia/nodame
# @license http://opensource.org/licenses/MIT
# 
# @version 1.0.0
###

Env = ->
  # set const variable
  PRODUCTION  = 'staging'
  DEVELOPMENT = 'development'
  STAGING     = 'staging'
  # default environment
  environment = DEVELOPMENT
  # list of release environments
  release_env = []
  # setup environment
  set: (settings, _release_env) ->
    release_env = _release_env
    # overwrite environment variable
    if settings.argv.staging? or settings.argv.production?
      # Set priority in case all were called.
      # Staging > Production
      if settings.argv.production?
        environment = PRODUCTION
      # Use staging if production is not set
      if settings.argv.staging?
        environment = STAGING
    else
      # Set priority in case both exist
      # settings.argv.env > process.env.NODE_ENV
      if process.env.NODE_ENV?
        environment = process.env.NODE_ENV
      # Use from argv if env is not set
      if settings.argv.env?
        environment = settings.argv.env
    # nothing to return
    return
  # return application's environment
  env: -> environment
  # return whether in development environment
  isDev: -> release_env.indexOf(environment) < 0
# export module
module.exports = Env()
