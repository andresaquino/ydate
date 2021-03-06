#!/bin/sh 
# vim: set ts=2 sw=2 sts=2 et si ai: 

# ydate.sh
# =-=
# This software is Free Software; it can be redistributed under the same terms as BSD Licence.
# All rights reserved.
#
# Authors
#   Carlos Aquiles < (at) mail.com>  
#   PetrOHS <petrohs(at) mail.com>
# Maintainer
#   Andres Aquino <andres.aquino(at) mail.com>
# 

# getNumberDay
# Get a number day taking the Gregorian Calendar as a baseline
# Params:
#   getNumberDay( string nday )
# Returns:
#   integer NumberDay
getNumberDay () {
  local mday="${1}"
  local number=
  
  # better, get date and split internally, use bc to cast values
  year=`echo ${mday} | cut -d'|' -f1 | bc`
  month=`echo ${mday} | cut -d'|' -f2 | bc`
  day=`echo ${mday} | cut -d'|' -f3 | bc`
  
  # values in range year > 0 || month > 0 || day > 0 => exit 1
  [ ${year} -le 0 -o ${month} -le 0 -o ${day} -le 0 ] && exit 1

  month=$(((month+9)%12))
  year=$((year-(month/10)))
  number=$(((365*year) + (year/4) - (year/100) + (year/400) + (month*306+5)/10 + (day-1)))

  echo $number
}

# getDayOfNumber
# Get a date from a NumberDay generated by getNumberDay function
# Params:
#   getDayOfNumber ( integer numberDay )
# Returns:
#   string dateCalculated
# 
getDayOfNumber () {
  local number=${1}
  local year=
  local month=
  local day=
 
  year=$(((10000*number+14780)/3652425))
  day=$((number-((365*year)+(year/4)-(year/100)+(year/400))))
  if [ ${day} -lt 0 ]
  then
    year=$((year-1))
    day=$((number-((365*year)+(year/4)-(year/100)+(year/400))))
  fi
  ydays=$((((100*day)+52)/3060))
  month=$((((ydays+2)%12)+1))
  year=$((year+(ydays+2)/12))
  day=$((day-((ydays*306+5)/10)+1))
  
  # formatting
  month=`echo "0000${month}" | rev | cut -c-2 | rev`
  day=`echo "0000${day}" | rev | cut -c-2 | rev`
  echo "${year}${month}${day}"

}

# sdate.sh 
# Params:
#   -d            by default -1 day
#   --days=-+N    move N days back or forward
#   -h | --help   show help
#
days=0
while [ $# -gt 0 ]
do
  case ${1} in
    -d)
      # opcion por defecto (-1)
      days=-1
      ;;
   --days| --days=*)
      # corrimiento de dias (+-N)
      days=`echo "${1}" | sed 's/^--days[=]*//'`
      [ ${#days} -eq 0 ] && days=-1 
      ;;
    -h|--help)
      echo "Usage: ydate [OPTIONS]..."
      echo "Calculate a date in the timeline by taking +-N days as parameter"
      echo "Mandatory arguments:"
      echo "  -d, --days=+N|-N                by default -1 day, otherwise +-N days"
      echo "  -h, --help                      show help"
      echo "Report bugs to <petrohs(at) mail.com>"
      exit 0
      ;;
    *)
      # opcion por defecto (-1)
      echo "Option not recognized, please check your parameters."
      echo "ydate --help"
      exit 0
      ;;
  esac
  shift
done

# get current date
ndate=`date '+%Y|%m|%d'`

# get number day
numberday=$(getNumberDay "${ndate}")

# apply n shift days
numberday=$((numberday+(days)))

# and finally, get a date
getDayOfNumber "${numberday}"

exit 0
