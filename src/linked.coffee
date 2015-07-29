###
# @author  Argi Karunia <https://github.com/hkyo89>
# @author  Originally by Teddy Hong <teddy.hong11@gmail.com>
# @link    https://github.com/tokopedia/nodame
# @license http://opensource.org/licenses/MIT
# 
# @version 1.0.0
###

class Links
  getLinked: (data = null) ->
    result = {}

    if data? and data.links?
      links = data.links
      for key of links
        type = links[key].type
        linked = data.linked

        if linked[type]?
          unless linked[type].error?
            result[type] = {}

            for i of linked[type]
              entry = linked[type][i]
              result[type][entry.id] = entry

    result

module.exports = new Links()
