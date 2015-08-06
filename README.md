![Nodame](https://lh4.googleusercontent.com/e8mR7D-KhqOW5B9XietJs8f2ld49EZjuQ7ldJlj68TxoGRE72iiWoOOHTWkCbwk-r5IARlutakWJ2baQAXvAZUKKfLX4JNO3wn3vo3u-1YcWGpEJrCho95CcgjWqJdRUpuzSog)

```bash
npm install nodame
```

***CURRENTLY UNSTABLE!!!***



- [Intro](#intro)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Run application](#run-application)
- [Release updates](#release-updates)
- [Features](#features)
    - [Routes](#routes)
    - [Menu](#menu)
    - [Handlers](#handlers)
    - [Services](#services)
    - [Middlewares](#middlewares)
    - [Views](#views)
    - [Assets manager](#assets-manager)
    - [Unit testing](#unit-testing)
    - [Public methods](#public-methods)
        - [nodame](#nodame)
        - [sprintf](#sprintf)
    - [Modules](#modules)
        - [Third-party modules](#third-party-modules)
        - [Custom modules](#custom-modules)
        - [Private modules](#private-modules)
            - [Datadog](#nodame-datadog)
            - [Date](#nodame-date)
            - [File](#nodame-file)
            - [HTML](#nodame-html)
            - [JsonApi](#nodame-jsonapi)
            - [Linked](#nodame-linked)
            - [Locale](#nodame-locale)
            - [Mailer](#nodame-mailer)
            - [Redis](#nodame-redis)
            - [Request](#nodame-request)
            - [Secret](#nodame-secret)
            - [Session](#nodame-session)
            - [String](#nodame-string)
            - [TOML](#nodame-toml)
            - [Validate](#nodame-validate)
            - [View](#nodame-view)

---
<a id="intro"></a>
## Intro
A [Node.js](https://nodejs.org/) framework built on [Express 4.0](http://expressjs.com/) with some [features](#features) to help in increasing development productivity. Nodame uses both [third-party](#third-party-modules) and [private](#private-modules) modules.  

It supports **cross-platform** development! You can freely develop your node team project directly on your laptop without needing a VM or anything!

---
<a id="prerequisites"></a>
## Prerequisites
- [x] [node.js](#https://nodejs.org)
- [x] [npm](#https://www.npmjs.com/) -- installed with node.js
- [ ] [mocha](#http://mochajs.org/) -- `npm install -g mocha` **(Only if you are going to use the unit testing)**

---
<a id="installation"></a>
## Installation
Installing Nodame is nothing more simpler than executing `npm install nodame`.

1. Create project directory

    ```bash
    mkdir ./new_project && cd ./new_project
    ```

2. Create package.json

    ```bash
    npm init
    ```

3. Install nodame package

    ```bash
    npm install --save nodame@~1.1.0
    ```

    > *Check the [release updates](#release-updates) for the latest stable version.*

4. Build project's files

    ```bash
    ./node_modules/nodame/build.sh
    ```

---
<a id="run-application"></a>
## Run application
You can [run your application](#run-application) by executing `index.js`. Your default project can be accessed through your browser at <http://localhost:3000/my-project>.

> *P.S.: You might want to set cookie domain to `""`, `NULL`, or `FALSE`; if you are using `localhost` as your domain. See [Cookie Specification](http://curl.haxx.se/rfc/cookie_spec.html).*

### Run using node command
```bash
node index.js [options]
```
|Option                    |Default          |Description                  |
|--------------------------|-----------------|-----------------------------|
|`-c`, `--config <file>`   |`./config-devel` |Config file location         |
|`-e`, `--env <env>`       |`development`    |Application environment      |
|`-S`, `--staging`         |                 |Set staging environment      |
|`-P`, `--production`      |                 |Set production environment   |
|`-p`, `--port`            |                 |Set port                     |
|`-t`, `--test`            |                 |Run test                     |

Example:

    ```bash
    node index.js --config ~/config/main.ini
    ```

### Run using nodemon  
1. Install nodemon

    ```bash
    npm install -g nodemon
    ```

    > This will install nodemon globally

2. Run nodemon

    ```bash
    nodemon index.js [option]
    ```

---
<a id="release-updates"></a>
## Release updates
| Release           | Version |
| ----------------- | ------- |
| Stable            | 1.1.0   |
| Release candidate | -       |  

### Changes history
- 1.0.6
    - Fixed Windows assets issue
- 1.0.5
    - Fixed Windows path issue
- 1.0.4
    - Added support to cross-platform development
    - Added `nodame/path` module
- 1.0.3
    - Added xml parser support to `req.body`
- 1.0.2
    - Added support to session token hook
- 1.0.1
    - Deprecated `nodame.service()`, changed to `nodame.require('service/')`
    - Deprecated `nodame.middleware()`, changed to `nodame.require('middleware/')`
    - Deprecated `nodame.handler()`, changed to `nodame.require('handler/')`
- **1.0.0**
    - **Public release to [npm](https://www.npmjs.com/package/nodame)**
    - Added hook support to run on system boot
- 0.2.2
    - Added support to set header in request
    - Added support to post XML in request
    - Fixed assets manager bug
- 0.2.1
    - Changed self passing variable in config file to `{{config.name}}`
    - Added support to argv
    - Fixed assets manager bug  
- 0.2.0
    - Added support to self passing variable in config file using `%config.name%`
    - Added support to URL encode in config file using `(config_value|encode_url)`
    - Removed support to bower  
- 0.1.0
    - Added support to bower
    - Extracted from team's project

---
<a id="features"></a>
## Features
- [ ] TODO: Complete this section.  

<a id="routes"></a>
### Routes
- [ ] TODO: Complete this section.  

Automates routing as defined in config.

<a id="menu"></a>
### Menu
- [ ] TODO: Complete this section.  

Auto-config menu.

<a id="handlers"></a>
### Handlers
- [ ] TODO: Complete this section.  

Handlers.

<a id="services"></a>
### Services
- [ ] TODO: Complete this section.  

Services.

<a id="middlewares"></a>
### Middlewares
- [ ] TODO: Complete this section.  

Middlewares.

<a id="views"></a>
### Views
- [ ] TODO: Complete this section.  

Views.

<a id="assets-manager"></a>
### Assets manager
- [ ] TODO: Complete this section.  

Provides automated assets generation of javascript and stylesheet files for production. It minifies and combines assets as defined in config.

<a id="unit-testing"></a>
### Unit testing
- [ ] TODO: Complete this section.  

Unit testing using BDD style.

<a id="public-methods"></a>
### Public methods
- [ ] TODO: Complete this section.  

Public methods are methods or objects that can be ran throughout the environment.

<a id="nodame"></a>
#### nodame
- `nodame.appPath()`  
Return application's absolute path.  

    ```javascript
    var appPath = nodame.appPath();
    // return '/absolute/path/to/app'
    ```

- `nodame.argv`  
Return argv object  

    ```bash
    node index.js --env development
    ```

    ```javascript
    var env = nodame.argv.env;
    // return 'development'
    ```

- `nodame.config()`  
Return config's value by passing selector. Please see `nodame.settings` for direct access to config's object.

    ```javascript
    var baseUrl = nodame.config('server.url.base');
    // return server.url.base in config
    ```

- `nodame.enforceMobile()`  
Middleware to enforce mobile view. *Not to be used in application.*  
- `nodame.env()`  
Return application's environment

    ```javascript
    var env = nodame.env();
    return 'development'
    ```

- `nodame.express()`
Return new Express' object.  

    ```javascript
    var express = nodame.express();
    // return new express' object
    ```

- `nodame.handler(name string)`
**Deprecated in 1.0.1.** Please see `nodame.require()`
- `nodame.isDev()`
Return whether it's development environment. Production and staging are considered as non-development environment.

    ```javascript
    if (nodame.isDev()) {
        console.log('Hello Dev!');
    }
    ```

- `nodame.locals()`
Middleware to register locals variable. *Not to be used in application.*
- `nodame.middleware()`
**Deprecated in 1.0.1.** Please see `nodame.require()`
- `nodame.require(name string)`
Native's require wrapper. You are encouraged to use this method instead of native's method as the native method won't load npm modules imported by nodame and nodame modules.

    ```javascript
    var path = nodame.require('path');
    // return native's module path
    var request = nodame.require('nodame/request');
    // return nodame module request
    var foo = nodame.require('module/foo');
    // return custom module foo as located in /modules
    ```

- `nodame.router()`
Return new express.Router().

    ```javascript
    var router = nodame.router();
    // return express.Router()
    ```

- `nodame.service(name string)`
**Deprecated in 1.0.1.** Please see `nodame.require()`
- `nodame.set(name string, obj object)`
Register object to `nodame.settings.__systems`. *Not to be used in application.*
- `nodame.settings`
Return settings value directly. This is a call to `nodame.setting`. You can use this to return config value directly by using `nodame.settings.config`, for calling config indirectly please see `nodame.config()`.

    ```javascript
    var baseUrl = nodame.settings.config.server.url.base;
    // return server.url.base
    ```

- `nodame.sysPath()`
Return system's path. *Not to be used in application.*

<a id="sprintf"></a>
#### `sprintf`
- `sprintf(string format , [mixed arg1 [, mixed arg2 [ ,...]]])`
Public method to [sprintf](https://www.npmjs.com/package/sprintf-js)

    ```javascript
    var foo = 'wooof';
    var bar = 'booo!';
    var str = sprintf('It sounds like %s but actually %s', foo, bar);
    // return 'It sounds like wooof but actually booo!'
    ```

- `vsprintf()`
Same as `sprintf()` but accept arrays.

    ```javascript
    var foo = vsprintf('The first 4 letters of the english alphabet are: %s, %s, %s and %s', ['a', 'b', 'c', 'd']);
    // return 'The first 4 letters of the english alphabet are: a, b, c, d'
    ```

<a id="modules"></a>
### Modules
Nodame comes with [third-party modules](#third-party-modules) and [private modules](#private-modules) which can be used using `nodame.require()`.

#### Third party modules
|Name                                                             |Version |
|-----------------------------------------------------------------|--------|
|[async](https://www.npmjs.com/package/async)                     |~0.9.0  |
|[body-parser](https://www.npmjs.com/package/body-parser)         |~1.10.2 |
|[colors](https://www.npmjs.com/package/colors)                   |~1.0.3  |
|[commander](https://www.npmjs.com/package/commander)             |~2.8.1  |
|[cookie-parser](https://www.npmjs.com/package/cookie-parser)     |~1.3.3  |
|[debug](https://www.npmjs.com/package/debug)                     |~2.1.1  |
|[express](https://www.npmjs.com/package/express)                 |~4.11.1 |
|[express-device](https://www.npmjs.com/package/express-device)   |~0.3.11 |
|[express-xml-bodyparser](https://www.npmjs.com/package/express-xml-bodyparser)   |~0.0.7 |
|[js-sha512](https://www.npmjs.com/package/js-sha512)             |^0.2.2  |
|[jumphash](https://www.npmjs.com/package/jumphash)               |^0.2.2  |
|[log](https://www.npmjs.com/package/log)                         |~1.4.0  |
|[mandrill-api](https://www.npmjs.com/package/mandrill-api)       |~1.0.41 |
|[md5](https://www.npmjs.com/package/md5)                         |^2.0.0  |
|[measure](https://www.npmjs.com/package/measure)                 |^0.1.1  |
|[method-override](https://www.npmjs.com/package/method-override) |~2.3.2  |
|[morgan](https://www.npmjs.com/package/morgan)                   |~1.5.2  |
|[node-dogstatsd](https://www.npmjs.com/package/node-dogstatsd)   |0.0.6   |
|[node-uuid](https://www.npmjs.com/package/node-uuid)             |~1.4.3  |
|[numeral](https://www.npmjs.com/package/numeral)                 |~1.5.3  |
|[parse-duration](https://www.npmjs.com/package/parse-duration)   |^0.1.1  |
|[query-string](https://www.npmjs.com/package/query-string)       |~1.0.0  |
|[raven](https://www.npmjs.com/package/raven)                     |^0.7.3  |
|[redis](https://www.npmjs.com/package/redis)                     |~0.12.1 |
|[serve-static](https://www.npmjs.com/package/serve-static)       |~1.9.2  |
|[sprintf-js](https://www.npmjs.com/package/sprintf-js)           |~1.0.2  |
|[swig](https://www.npmjs.com/package/swig)                       |~1.4.2  |
|[validate.js](https://www.npmjs.com/package/validate.js)         |~0.6.1  |

#### Private modules
<a id="nodame-datadog"></a>
##### Datadog
<a id="nodame-date"></a>
##### Date
<a id="nodame-file"></a>
##### File
<a id="nodame-html"></a>
##### HTML
<a id="nodame-jsonapi"></a>
##### JsonApi
<a id="nodame-linked"></a>
##### Linked
<a id="nodame-locale"></a>
##### Locale
<a id="nodame-mailer"></a>
##### Mailer
<a id="nodame-redis"></a>
##### Redis
<a id="nodame-request"></a>
##### Request
<a id="nodame-secret"></a>
##### Secret
<a id="nodame-session"></a>
##### Session
<a id="nodame-string"></a>
##### String
<a id="nodame-view"></a>
##### View

---
> **<>** with **❤︎** by **ドラえもん**
