function locals(app) {
    var configs = {
        url: helper.config.get('server.url'),
        app: helper.config.get('app'),
        assets: helper.config.get('assets')
    };

    for (var config in configs) {
        app.locals[config] = new Object();

        for (var key in configs[config]) {
            app.locals[config][key] = configs[config][key];
        }
    }
}

module.exports = locals;
