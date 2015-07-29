###
# @author  Argi Karunia <arugikaru@yahoo.co.jp>
# @link    https://github.com/tokopedia/nodame
# @license http://opensource.org/licenses/MIT
#
# @version 1.0.0
###

class StrConv
  btoi: (val) ->
    if val? and typeof val == 'boolean'
      return if val then 1 else 0

module.exports = new StrConv()
