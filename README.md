kereta-api ticketing
====================

#### Instructions
1. Install `node.js (v0.10.25)`

  `http://nodejs.org/dist/v0.10.25/`

2. Install dependencies
   To install dependencies execute command `npm install` inside the cloned repository where `package.json` is located.

3. Install express-generator (Optional)
   To install express-generator execute command `npm install express-generator@4.11.1 -g`

4. Copy src/config to src/config-devel, and create main.ini from default.ini.


#### Helper

`helper.load.util(name);`
`helper.load.service(name);`
`helper.load.handler(name);`


#### Private Utilities
Call private utilities using this method:
`var path = require(UTIL)('path');`

Path Utility
This utility has `view` method which will automatically generate view's path according to device type and template used in application.

Generate view's path:
`path.view(http.request, moduleName, htmlFile);`

Example:
`path.view(req, 'home', 'index');`

will generate:
`/mobile/default/home/index`

#### Notes
- Y
