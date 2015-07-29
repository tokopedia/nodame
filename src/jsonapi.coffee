###
# @author  Argi Karunia <https://github.com/hkyo89>
# @link    https://github.com/tokopedia/nodame
# @license http://opensource.org/licenses/MIT
#
# @version 1.0.0
###

class JsonApi
  parse: (data) ->
    result = {}
    try
      result = JSON.parse data
    catch error
      console.log console.error

    result

module.exports = new JsonApi()
