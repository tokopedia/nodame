var redis = require("redis");
var md5 = require('MD5');
var jumphash = require('jumphash');

var parent = this;

var redisPool = {};

exports.getClient = function (mapShard, replication, key) {
    var configRedis = helper.config.get('redis');
    var conn        = configRedis.map[mapShard];

    if(conn.length > 0) {
        if(!replication) {
            replication = 'master';
        }
        if(!key) {
            key = 1;
        }

        // console.log('mapShard', mapShard);
        // console.log('replication', replication);
        // console.log('key', key);

        var indexShard = jumphash(key, conn.length);
        // console.log('indexShard', indexShard);

        var connectionString = 'redis:' +  conn[indexShard] + ':' + replication;
        // console.log('connectionString', connectionString);

        var connectionId = md5(connectionString);
        // console.log('connectionId', connectionId);
        // console.log('conn', conn);

        var redisGroup = configRedis[conn[indexShard]];

        var redisConTemp = redisGroup[replication].split(':');
        // console.log('redisConTemp', redisConTemp);

        if(!redisPool[connectionId]) {
            redisPool[connectionId] = redis.createClient(redisConTemp[1], redisConTemp[0], {});
        }

        return redisPool[connectionId];
    }
}
