module.exports = (function () {
    var self = this;

    var hello = function (name) {
        return sprintf('Hello %s!', name);
    };

    return {
        hello: hello
    }
})();
