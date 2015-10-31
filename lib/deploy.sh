#
# Deploys the site to the branch configured, usually the gh-pages
# branch
#


# Stop on error
set -e


# utilities
source .travis/utils.sh
source .travis/config.sh


# script variables
LOG_TITLE="deploy"


log "cloning repo (afresh)" 0
git clone "${REPO_URL}" _repo


log "cd into repo and checkout gh-pages branch" 0
cd _repo
git checkout "${BRANCH}"


log "rm all files" 0
git rm -rf *
rm -rf *


log "copying gitbook output to gh-pages branch" 0
cp -r ../${DEST_DIR}/* .


log "configuring git" 0
git config user.email "${USER_EMAIL}" 0
git config user.name "${USER_NAME}"


log "adding and committing changes" 0
git add -A .
git commit -a -m "Build ${TRAVIS_BUILD_NUMBER}"


log "adding authentication key (belongs to ${USER_NAME})" 0
echo -e "machine github.com\n  login ${USER_EMAIL}\n  password ${GH_TOKEN}" >> ~/.netrc


log "pushing changes to remote" 0
git push origin ${BRANCH} > /dev/null \
  && log "successful deployment" 1 \
  || log "failed deployment" 2

