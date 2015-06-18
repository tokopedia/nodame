var redis       = require("redis");
var md5         = nodame.import('MD5');
var jumphash    = nodame.import('jumphash');
var parent      = this;
var redisPool   = {};

exports.getClient = function (mapShard, replication, key) {
    var configRedis = nodame.config.get('redis');
    var conn        = configRedis.map[mapShard];

    if (conn.length > 0) {
        if (!replication) {
            replication = 'master';
        }

        if (!key) {
            key = 1;
        }

        var indexShard          = jumphash(key, conn.length);
        var connectionString    = 'redis:' +  conn[indexShard] + ':' + replication;
        var connectionId        = md5(connectionString);
        var redisGroup          = configRedis[conn[indexShard]];
        var redisConTemp        = redisGroup[replication].split(':');

        if (!redisPool[connectionId]) {
            redisPool[connectionId] = redis.createClient(redisConTemp[1], redisConTemp[0], {});

            redisPool[connectionId].on("error", function (err) {
                console.log("Error Redis " + err);
            });
        }

        return redisPool[connectionId];
    }
}
