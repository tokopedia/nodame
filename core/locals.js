function locals(app) {
    var configs = {
        url: nodame.config.get('server.url'),
        app: nodame.config.get('app'),
        assets: nodame.config.get('assets')
    };

    for (var config in configs) {
        app.locals[config] = new Object();

        for (var key in configs[config]) {
            app.locals[config][key] = configs[config][key];
        }
    }
}

module.exports = locals;
