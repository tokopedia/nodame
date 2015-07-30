###
# @author  Argi Karunia <https://github.com/hkyo89>
# @author  Originally by Teddy Hong <https://github.com/teddyhong>
# @link    https://github.com/tokopedia/nodame
# @license http://opensource.org/licenses/MIT
#
# @version 1.0.0
###

class DateParser

  toDate: (time, format = '') ->
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

  toString: (date_str, format = 'normal') ->
    _date = new Date(date_str)
    # TODO: Move to config
    weekdays =
      Sun: 'Minggu'
      Mon: 'Senin'
      Tue: 'Selasa'
      Wed: 'Rabu'
      Thu: 'Kamis'
      Fri: 'Jumat'
      Sat: 'Sabtu'
    # TODO: Move to config
    months =
      Jan: { word: 'Januari',   num: 1  }
      Feb: { word: 'Februari',  num: 2  }
      Mar: { word: 'Maret',     num: 3  }
      Apr: { word: 'April',     num: 4  }
      May: { word: 'Mei',       num: 5  }
      Jun: { word: 'Juni',      num: 6  }
      Jul: { word: 'Juli',      num: 7  }
      Aug: { word: 'Agustus',   num: 8  }
      Sep: { word: 'September', num: 9  }
      Oct: { word: 'Oktober',   num: 10 }
      Nov: { word: 'November',  num: 11 }
      Dec: { word: 'Desember',  num: 12 }

    format_date = (match, $1, $2, $3, $4, offset, original) ->
      switch format
        when 'normal'
          result = "#{weekdays[$1]}, #{$3} #{months[$2].word} #{$4}"
        when 'short'
          result = "#{lead_zero($3)}/#{$2}/#{$4}"
      return result

    replace_date = ->
      re = ///^
      ([a-z]{1,3})\         # $1 short day
      ([a-z]{1,3})\         # $2 short month
      ([0-9]{1,2})\         # $3 date
      ([0-9]{1,4})\         # $4 year
      ([0-9]{1,2}):         # $5 hours
      ([0-9]{1,2}):         # $6 minutes
      ([0-9]{1,2})\         # $7 seconds
      GMT([-+][0-9]{1,4})\  # $8 GMT
      (\([a-z ]+\))         # $9 timezone
      $///i

      return _date.toString().replace(re, format_date)

    return replace_date()

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
