#
# Installs our dependencies
#


# Stop on error
set -e


# utilities
source .travis/utils.sh


# script variables
LOG_TITLE="deps"


command -v gitbook > /dev/null 2>&1 || {
  log "installing gitbook globally" 0
  npm install -g gitbook-cli
}

