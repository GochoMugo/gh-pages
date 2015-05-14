#
# Overly-used utilities
#


# Colors for Bash
COLOR_BLUE="\033[0;34m"
COLOR_GREEN="\033[0;32m"
COLOR_RED="\033[0;31m"
COLOR_RESET="\e[0m"
COLOR_WHITE="\033[1;37m"


# logs to console
#
# ${1}  message to write to console
# ${2} what color to use. 0 - info(blue), 1- success(green),
#   2 - error(red)
# ${LOG_TITLE} for setting title of logging
log() {
  if [ ! ${2} -eq -1 ] ; then
    [ ${2} -eq 0 ] && local color=${COLOR_BLUE}
    [ ${2} -eq 1 ] && local color=${COLOR_GREEN}
    [ ${2} -eq 2 ] && local color=${COLOR_RED}
    echo -e "${COLOR_WHITE}${LOG_TITLE}: ${color}${1}${COLOR_RESET}"
  else
    echo "${1}"
  fi
}

