###
# @author  Argi Karunia <https://github.com/hkyo89>
# @author  Originally by Teddy Hong <https://github.com/teddyhong>
# @link    https://github.com/tokopedia/nodame
# @license http://opensource.org/licenses/MIT
#
# @version 1.0.0
###

class DateParser
  parseDate: (time, format = '') ->
    if time?
      if format is 'dd-mm-yyyy'
        temp  = time.split '-'
        time  = "#{temp[2]}#{temp[1]}#{temp[0]}"

      time  = String(time)
      year  = time.substring(0, 4)
      month = time.substring(4, 6) - 1
      day   = time.substring(6, 8)
      hour  = time.substring(8, 10)
      min   = time.substring(10, 12)
      result = new Date(year, month, day, hour, min)
      return unless result is 'Invalid Date' then result else false
    return

  parseString: (time) ->
    if time instanceof Date
      year  = time.getFullYear()
      month = "0#{(time.getMonth() + 1)}".slice(-2)
      day   = "0#{time.getDate()}".slice(-2)
      "#{year}#{month}#{day}"
    else
      false;

  calculateAge: (birthday) ->
    ageDifMs = Date.now() - birthday.getTime()
    if ageDifMs < 0
      return -1

    ageDate = new Date(ageDifMs)
    return Math.abs(ageDate.getUTCFullYear() - 1970)

  getOptDate: ->
    day for day in [1..31]

  getOptMonth: ->
    months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
    {name: month, value: i + 1} for month, i in months

  getOptYear: (totalYear = 20, start = 0) ->
    currentYear = new Date().getFullYear()
    endYear     = currentYear + (start)
    startYear   = endYear - totalYear
    year for year in [startYear..endYear]

module.exports = new DateParser()
