# nodame
- latest version: 0.2.0
- latest stable version: 0.2.0

## Prerequisites
- Node.js (~0.12.4)

## Installation
1. Create *project directory*
   ```bash
   mkdir new_project && new_project
   ```

2. Create *package.json*
   ```bash
   npm init
   ```

3. Install *nodame*
   ```bash
   npm install --save tokopedia/nodame#0.2.0
   ```

4. Build files
   ```bash
   ./node_modules/nodame/build.sh
   ```

## Configuration Files
Coming soon

## Run Application
```bash
node node_modules/nodame [options]
```
|Option                    |Default          |Description                  |
|--------------------------|-----------------|-----------------------------|
|`-c`, `--config <file>`   |`./config-devel` |Config file location         |
|`-e`, `--env <env>`       |`development`    |Application environment      |
|`-s`, `--staging`         |                 |Set staging environment      |
|`-p`, `--production`      |                 |Set production environment   |

Example:
```bash
node node_modules/nodame --config ~/config/main.ini
```

## Built in method
#### `nodame.router()`
Loads express.Router()
Usage:
```javascript
var router = nodame.router();
```
#### `nodame.require(moduleName)`
Loads node's module. You are highly encouraged to use `nodame.require()` instead of plain `require()`. This is the way to load inherited and your custom modules.
Usage:
```javascript
// Load nodame's module
var request = nodame.require('nodame/request');
// Load node's module
var path    = nodame.require('path');
// Load your custom module
var foo     = nodame.require('my_modules/foo');
```
#### `nodame.handler(handlerName)`
Loads application's handler. _Note: you will most-likely not be going to use this method.
Usage:
```javascript
var home = nodame.handler('home');
```

#### `nodame.service(serviceName)`
Loads application's service.
Usage:
```javascript
var homeService = nodame.service('home');
```

#### `to be continued`

## Modules
This is the list of both inherited and nodame's modules. You don't need to install the modules anymore as it's already imported by nodame.

#### Inherited modules
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
|[js-sha512](https://www.npmjs.com/package/js-sha512)             |^0.2.2  |
|[jumphash](https://www.npmjs.com/package/jumphash)               |^0.2.2  |
|[log](https://www.npmjs.com/package/log)                         |~1.4.0  |
|[mandrill-api](https://www.npmjs.com/package/mandrill-api)       |~1.0.41 |
|[MD5](https://www.npmjs.com/package/MD5)                         |^1.2.1  |
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

#### Nodame's modules
- *nodame/datadog*
- *nodame/date*
- *nodame/file*
- *nodame/html*
- *nodame/jsonapi*
- *nodame/linked*
- *nodame/locale*
- *nodame/mailer*
- *nodame/redis*
- *nodame/request*
- *nodame/secret*
- *nodame/session*
- *nodame/string*
- *nodame/toml*
- *nodame/validate*
- *nodame/view*
