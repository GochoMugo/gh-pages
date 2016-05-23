#!/usr/bin/env bash
#
# Deploys the site to the branch configured, usually the gh-pages
# branch
#


# Stop on error
set -e


# utilities
source "${DATA_DIR}/utils.sh"
source "${DATA_DIR}/config.sh"


# script variables
LOG_TITLE="deploy"


log "ensuring site has been built" 0
if [ ! -e "${OUT_DIR}" ]
then
  log "site not built" 2
  exit 1
fi

log "cloning repo (afresh)" 0
git clone "${GIT_URL}" _repo


log "cd into repo and checkout '${BRANCH}' branch" 0
cd _repo
git checkout "${BRANCH}"


log "rm all files" 0
git rm -rf *
rm -rf *


log "copying output to gh-pages branch" 0
cp -r "../${OUT_DIR}"/* .


log "configuring git" 0
git config user.email "${USER_EMAIL}"
git config user.name "${USER_NAME}"


log "adding and committing changes" 0
git add -A .
git commit -a -m "Build ${TRAVIS_BUILD_NUMBER}"


log "adding authentication key (belongs to ${USER_NAME})" 0
echo -e "machine github.com\n  login ${USER_EMAIL}\n  password ${GH_TOKEN}" >> ~/.netrc


log "pushing changes to remote" 0
git push origin ${BRANCH} > /dev/null
if [ $? ]
then
  log "successful deployment" 1
else
  log "failed deployment" 2
  exit 1
fi
