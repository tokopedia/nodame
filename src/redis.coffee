redis       = require 'redis'
md5         = require 'md5'
jumphash    = require 'jumphash'
pool        = {}

class RedisClient
  getClient: (mapShard, replication = 'master', key = 1) ->
    config  = nodame.config 'cache.clients.redis'
    conn    = config.map[mapShard]

    if conn.length > 0
      index = jumphash key, conn.length
      connStr = "redis:#{conn[index]}:#{replication}"
      connId  = md5(connStr)
      group = config[conn[index]]
      connTmp = group[replication].split ':'

      unless pool[connId]?
        pool[connId] = redis.createClient connTmp[1], connTmp[0], {}
        pool[connId].on 'error', @_errorHandler

      pool[connId]

  _errorHandler: (err) ->
    console.log "Error Redis #{err}"

module.exports = new RedisClient()
