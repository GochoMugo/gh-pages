#
# Run Script
#
# MIT License
# Copyright (c) 2015 GochoMugo <mugo@forfuture.co.ke>
#


# modules
msu_require "console"


# script variables
DEPS="curl"
ROOT=$(dirname ${BASH_SOURCE[0]})  # directory holding this file
LIB="${ROOT}/lib"                  # path to our lib
TEMPLATES="${HOME}/.gh-pages/templates"  # installed templates

# templates
GITBOOK_URL="https://github.com/GochoMugo/gh-pages-gitbook.git"
JEKYLL_URL="https://github.com/GochoMugo/gh-pages-jekyll.git"

# github access tokens
SCOPES="[\"public_repo\"]"


# main entry point
function main() {

# ensure environment is ready for us.
mkdir -p "${TEMPLATES}"

case ${1} in
  "p" | "prepare" )
    # creating the directory for the scripts
    mkdir -p .travis

    # copying scripts from lib to the scripts directory
    cp -rf ${LIB}/* ${LIB}/.travis.yml .travis > /dev/null 2>&1

    # we might be using a template
    [ ${2} ] && {
      log "using template: ${2}"
      templateDir="$TEMPLATES/${2}"
      [ ! -d ${templateDir} ] && {
        error "missing template ${2}"
        exit 1
      }
      cp -rf ${templateDir}/* ${templateDir}/.travis.yml .travis > /dev/null 2>&1
    }

    # moving travis configuration file to root of cwd
    mv -i .travis/.travis.yml .
    success "done with preparation"
  ;;

  "f" | "finish" )
    # ensure the `travis` command is available
    command -v travis > /dev/null 2>&1 || {
      error "\`travis' command missing"
      error "please install \`travis' using: gem install travis"
      exit 1
    }

    # configuration file
    CONFIG_FILE=".travis/config.sh"

    # if the configuration file does not exist, we create for the user
    if [ ! -e ${CONFIG_FILE} ]
    then
      log "please fill in these details" 0
      BRANCH="gh-pages"
      DEST_DIR="_out"

      # if we are in a git repository
      if [ -d .git ]
      then
        REPO_URL="$(git remote -v | grep -Ei 'origin.*push' | grep -Eio '[a-z]+://.* ')"
        USER_NAME="$(git config user.name)"
        USER_EMAIL="$(git config user.email)"
      fi

      ask "Repository Url [$REPO_URL]:" REPO_URL
      ask "Branch to Deploy to [${BRANCH}]:" BRANCH
      ask "Output Directory [${DEST_DIR}]:" DEST_DIR
      ask "Github Username [${USER_NAME}]:" USER_NAME
      ask "Email Address [${USER_EMAIL}]:" USER_EMAIL

      # if token file does not exist, we should create it, by getting a github token
      # and placing it in the file.
      if [ ! -e .token ]
      then
        ask "Github Password" USER_PASS 1
        curl -s \
          -u ${USER_NAME}:${USER_PASS} \
          -X POST https://api.github.com/authorizations \
          --data "{\"scopes\": ${SCOPES}, \
            \"note\": \"gh-pages: ${REPO_URL}\"}" > .res
        cat .res \
          | grep -Ei "\"token\": " \
          | grep -Eio ": \"[a-z0-9]+" \
          | grep -Eio "[a-z0-9]+" > .token
      fi
      GH_TOKEN="$(cat .token)"

      # if we failed to generate an access token.
      [ ${GH_TOKEN} ] || {
        error "failed to generate an access token from Github"
        yes_no "show error response" "N" && {
          cat .res
          rm .res .token
        }
        exit 1
      }

      # we done with the response.
      rm .res

      # save the configurations to file.
      echo "REPO_URL=${REPO_URL}" >> ${CONFIG_FILE}
      echo "BRANCH=${BRANCH}" >> ${CONFIG_FILE}
      echo "DEST_DIR=${DEST_DIR}" >> ${CONFIG_FILE}
      echo "USER_NAME=${USER_NAME}" >> ${CONFIG_FILE}
      echo "USER_EMAIL=${USER_EMAIL}" >> ${CONFIG_FILE}

      # use `travis` to encrypt the access token.
      travis encrypt GH_TOKEN=${GH_TOKEN} \
        --skip-version-check --add || {
        error "failed encrypting with \`travis'"
        error "note that your github access token has been saved to .token"
        error "ensure you do NOT commit this file"
        error "RETRY! On success, .token will be auto-deleted"
        rm ${CONFIG_FILE}
        exit 1
      }

      # we have encrypted the access token unto travis servers.
      rm .token
      success "finished!"
    fi
  ;;

  "t" | "template" )
    [ ${2} ] || {
      error "template name is required"
      exit 1
    }

    [ ${3} ] || {
      error "git url is required"
      exit 1
    }

    # move to tempdir for hygiene purposes.
    pushd /tmp/ > /dev/null

    # if a previous run had occurred before this, ensure it is clean.
    rm -rf template

    # clone the template's repo.
    git clone ${3} template > /dev/null 2>&1 && {
      # remove previous installations, and install this template.
      rm -rf ${TEMPLATES}/${2}
      mv template ${TEMPLATES}/${2}
      tick "${2}"
    } || {
      error "failed to clone ${2}'s repo"
      exit 1
    }
  ;;

  "r" | "recommended-templates" )
    # gitbook template.
    yes_no "gitbook" "y" && {
      msu run gh-pages.main.main template gitbook ${GITBOOK_URL}
    }

    # jekyll template.
    yes_no "jekyll" "y" && {
      msu run gh-pages.main.main template jekyll ${JEKYLL_URL}
    }

    exit 0
  ;;

  "v" | "version" )
    msu version gh-pages
  ;;

  "u" | "upgrade" )
    log "upgrading to the latest version"
    msu install gh:GochoMugo/gh-pages
  ;;

  "i" | "info" | "h" | "help" | * )
    echo
    echo " Preparing Repos:"
    echo "    ⇒ gh-pages prepare [template-name]"
    echo
    echo " Finishing on Repos:"
    echo "    ⇒ gh-pages finish"
    echo
    echo " Adding templates:"
    echo "    ⇒ gh-pages template <name> <git-url>"
    echo
    echo " Scripts run on Travis during each Build:"
    echo "    .travis/deps.sh -- install dependencies"
    echo "    .travis/build.sh -- build your website"
    echo "    .travis/deploy.sh -- deploys the site"
    echo
    echo " Other Scripts:"
    echo "    .travis/config.sh -- your configuration information"
    echo
    echo " Other commands:"
    echo "    ⇒ gh-pages version # show version information"
    echo "    ⇒ gh-pages upgrade # upgrade gh-pages"
    echo
    echo " More Information:"
    echo "    You can easily install recommended templates using"
    echo "     ⇒ gh-pages recommended-templates"
    echo
  ;;
esac

}

