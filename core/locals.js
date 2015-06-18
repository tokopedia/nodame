function locals(app) {
    var configs = {
        url: nodame.config('server.url'),
        app: nodame.config('app'),
        assets: nodame.config('assets')
    };

    for (var config in configs) {
        app.locals[config] = new Object();

        for (var key in configs[config]) {
            app.locals[config][key] = configs[config][key];
        }
    }
}

module.exports = locals;
