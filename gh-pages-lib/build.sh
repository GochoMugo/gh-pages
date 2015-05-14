#
# Building the Website using gitbook
#


# Stop on error
set -e


# utilities
source .travis/utils.sh


# script variables
LOG_TITLE="build"


log "building using gitbook" 0
gitbook build

