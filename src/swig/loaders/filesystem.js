var fs = require('fs'),
  path = require('path');

/**
 * Loads templates from the file system.
 * @alias swig.loaders.fs
 * @example
 * swig.setDefaults({ loader: swig.loaders.fs() });
 * @example
 * // Load Templates from a specific directory (does not require using relative paths in your templates)
 * swig.setDefaults({ loader: swig.loaders.fs(__dirname + '/templates' )});
 * @param {string}   [basepath='']     Path to the templates as string. Assigning this value allows you to use semi-absolute paths to templates instead of relative paths.
 * @param {string}   [encoding='utf8']   Template encoding
 */
module.exports = function (basepath, encoding) {
  var ret = {};

  encoding = encoding || 'utf8';
  basepath = (basepath) ? path.normalize(basepath) : null;

  /**
   * Resolves <var>to</var> to an absolute path or unique identifier. This is used for building correct, normalized, and absolute paths to a given template.
   * @alias resolve
   * @param  {string} to        Non-absolute identifier or pathname to a file.
   * @param  {string} [from]    If given, should attempt to find the <var>to</var> path in relation to this given, known path.
   * @return {string}
   */
  ret.resolve = function (to, from) {
    if (basepath) {
      from = basepath;
    } else {
      from = (from) ? path.dirname(from) : process.cwd();
    }
    return path.resolve(from, to);
  };

  /**
   * Loads a single template. Given a unique <var>identifier</var> found by the <var>resolve</var> method this should return the given template.
   * @alias load
   * @param  {string}   identifier  Unique identifier of a template (possibly an absolute path).
   * @param  {function} [cb]        Asynchronous callback function. If not provided, this method should run synchronously.
   * @return {string}               Template source string.
   */
  ret.load = function (identifier, cb) {
    // Argi Karunia: for temporary data
    var data;

    if (!fs || (cb && !fs.readFile) || !fs.readFileSync) {
      throw new Error('Unable to find file ' + identifier + ' because there is no filesystem to read from.');
    }

    // Argi Karunia: Try reading from memory
    // Argi Karunia: Check if the templates object exists
    if (nodame.settings.templates === undefined) {
        nodame.settings.templates = {};
    }
    // Argi Karunia: Check if template exists
    if (nodame.settings.templates[identifier]) {
        data = nodame.settings.templates[identifier];
        // Argi Karunia: Return callback if called
        if (cb) {
          cb(null, data);
          return;
        }
        // Argi Karunia: Return data
        return data;
    }

    identifier = ret.resolve(identifier);
    // Argi Karunia: We don't use this for callback
    if (cb) {
      fs.readFile(identifier, encoding, function(err, data) {
          // Argi Karunia: Store to memory so we don't need to read from file again
          // Argi Karunia: Add empty space to avoid empty file being skipped
          nodame.settings.templates[identifier] = data + " ";
          // Argi Karunia: Return callback
          cb(err, data);
      });
      return;
    }

    // Argi Karunia: Read file sync-ly
    data = fs.readFileSync(identifier, encoding);
    // Argi Karunia: Store to memory so we don't need to read from file again
    // Argi Karunia: Add empty space to avoid empty file being skipped
    nodame.settings.templates[identifier] = data + " ";
    // Argi Karunia: Return the template
    return data;
  };

  return ret;
};
