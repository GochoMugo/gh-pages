#!/usr/bin/env msu
#
# Run Script
#
# MIT License
# Copyright (c) 2015-2016 GochoMugo <mugo@forfuture.co.ke>
#


# modules
msu_require "console"


# script variables
GH_PAGES_VERSION="1.0.0"
DEPS="curl travis"
ROOT=$(dirname ${BASH_SOURCE[0]})  # directory holding this file
LIB="${ROOT}/lib"                  # path to our lib
TEMPLATES_DIR="${GH_PAGES_TEMPLATES_DIR:-${ROOT}/templates}" # installed templates
DATA_DIR="${GH_PAGES_DATA_DIR:-.gh-pages}" # name of the directory to store data
CONFIG_FILE="${DATA_DIR}/config.sh" # configuration file


# templates
GITBOOK_URL="https://github.com/GochoMugo/gh-pages-gitbook.git"
JEKYLL_URL="https://github.com/GochoMugo/gh-pages-jekyll.git"

# github access tokens
SCOPES="[\"public_repo\"]"


# main entry point
#
# ${1} - action e.g. 'init'
function main() {

# ensure environment is ready for us.
mkdir -p "${TEMPLATES_DIR}" "${DATA_DIR}"

case ${1} in
  "i" | "init" )
    # copying scripts from lib to the scripts directory
    cp -rf "${LIB}"/* "${LIB}"/.travis.yml "${DATA_DIR}" > /dev/null 2>&1

    # we might be using a template
    [ ${2} ] && {
      log "using template: ${2}"
      templateDir="${TEMPLATES_DIR}/${2}"
      [ ! -d ${templateDir} ] && {
        error "missing template ${2}"
        return 1
      }
      cp -rf "${templateDir}"/* "${templateDir}/.travis.yml" "${DATA_DIR}" > /dev/null 2>&1
    }

    # ensure the `travis` command is available
    command -v travis > /dev/null 2>&1 || {
      error "\`travis' command missing"
      error "please install \`travis' using: \`gem install travis'"
      return 1
    }

    # if the configuration file does not exist, we create for the user
    if [ ! -e "${CONFIG_FILE}" ]
    then
      log "please fill in these details"
      DEFAULT_BRANCH="gh-pages"
      DEFAULT_OUT_DIR="_out"

      # if we are in a git repository
      if [ -d .git ]
      then
        DEFAULT_USER_NAME="$(git config user.name)"
        DEFAULT_USER_EMAIL="$(git config user.email)"
        DEFAULT_GIT_URL="https://github.com/${DEFAULT_USER_NAME}/$(basename "$PWD").git"
      fi

      ask "Repository Git Url [${DEFAULT_GIT_URL}]:" GIT_URL
      ask "Branch to Deploy to [${DEFAULT_BRANCH}]:" BRANCH
      ask "Output Directory [${DEFAULT_OUT_DIR}]:" OUT_DIR
      ask "Github Username [${DEFAULT_USER_NAME}]:" USER_NAME
      ask "Email Address [${DEFAULT_USER_EMAIL}]:" USER_EMAIL

      [[ -z "${GIT_URL}" ]] && GIT_URL="${DEFAULT_GIT_URL}"
      [[ -z "${BRANCH}" ]] && BRANCH="${DEFAULT_BRANCH}"
      [[ -z "${OUT_DIR}" ]] && OUT_DIR="${DEFAULT_OUT_DIR}"
      [[ -z "${USER_NAME}" ]] && USER_NAME="${DEFAULT_USER_NAME}"
      [[ -z "${USER_EMAIL}" ]] && USER_EMAIL="${DEFAULT_USER_EMAIL}"

      # save the configurations to file.
      rm -f "${CONFIG_FILE}"
      echo "GIT_URL=\"${GIT_URL}\"" >> ${CONFIG_FILE}
      echo "BRANCH=\"${BRANCH}\"" >> ${CONFIG_FILE}
      echo "OUT_DIR=\"${OUT_DIR}\"" >> ${CONFIG_FILE}
      echo "USER_NAME=\"${USER_NAME}\"" >> ${CONFIG_FILE}
      echo "USER_EMAIL=\"${USER_EMAIL}\"" >> ${CONFIG_FILE}
      echo "source \""${CONFIG_FILE}"\" ; echo \"$(cat "${DATA_DIR}/.travis.yml")\"" | \
        DATA_DIR="${DATA_DIR}" bash > .travis.yml
    fi

    # if token file does not exist, we should create it, by getting a github token
    # and placing it in the file.
    if [ ! -e .token ]
    then
      log "We are about to create a Github personal token, just for this repository"
      log "The password request is NOT saved at all"
      log "Should you feel uncomfortable or this request fails due to\n\
     2FA, etc., you may create a personal token at\n\
     https://github.com/settings/tokens/new and place it in a\n\
     file named '.token' in this directory and re-run this command."
      yes_no "Continue to automated-token creation" || return 2

      ask "Github Password" USER_PASS 1
      log "Sending request for new access token"
      curl -s \
        -u ${USER_NAME}:${USER_PASS} \
        -X POST https://api.github.com/authorizations \
        --data "{\"scopes\": ${SCOPES}, \
          \"note\": \"gh-pages: ${GIT_URL}\"}" > .res
      cat .res \
        | grep -Ei "\"token\": " \
        | grep -Eio ": \"[a-z0-9]+" \
        | grep -Eio "[a-z0-9]+" > .token

      # if we failed to generate an access token.
      [ "$(cat .token)" ] || {
        error "failed to generate an access token from Github"
        yes_no "show error response" && {
          cat .res
          rm -f .res .token
        }
        return 2
      }

      # we done with the response.
      rm .res
    fi

    # read the token
    GH_TOKEN="$(cat .token)"

    # use `travis` to encrypt the access token.
    log "encrypting token, using \`travis'"
    travis encrypt GH_TOKEN=${GH_TOKEN} \
      --skip-version-check --add || {
      error "failed encrypting with \`travis'"
      error "note that your github access token has been saved to .token"
      error "ensure you do NOT commit this file"
      error "RETRY! On success, .token will be auto-deleted"
      return 2
    }

    # we have encrypted the access token unto travis servers.
    rm .token

    success "finished!"
  ;;

  "t" | "template" )
    [ ${2} ] || {
      error "template name is required"
      return 1
    }

    [ ${3} ] || {
      error "git url is required"
      return 1
    }

    # move to tempdir for hygiene purposes.
    pushd /tmp/ > /dev/null

    # if a previous run had occurred before this, ensure it is clean.
    rm -rf gh-template

    # clone the template's repo.
    git clone ${3} gh-template > /dev/null 2>&1 && {
      # remove previous installations, and install this template.
      rm -rf "${TEMPLATES_DIR}/${2}"
      mv gh-template "${TEMPLATES_DIR}/${2}"
      tick "${2}"
    } || {
      error "failed to clone ${2}'s repo"
      return 1
    }
  ;;

  "l" | "templates" )
    for dir in "${TEMPLATES_DIR}"/*
    do
      template="$(basename ${dir})"
      [[ "${template}" == "*" ]] && return
      list "${template}"
    done
  ;;

  "r" | "recommended-templates" )
    # jekyll template.
    yes_no "jekyll" "y" && {
      main template jekyll ${JEKYLL_URL}
    }
  ;;

  "v" | "version" )
    msu version gh-pages
  ;;

  "u" | "upgrade" )
    log "upgrading to the latest version"
    msu install gh:GochoMugo/gh-pages
  ;;

  "info" | "h" | "help" | * )
    echo
    echo " gh-pages v${GH_PAGES_VERSION}"
    echo
    echo " Initialize:"
    echo "    ⇒ gh-pages init [template-name]"
    echo
    echo " Adding templates:"
    echo "    ⇒ gh-pages template <name> <git-url>"
    echo
    echo " Scripts run on Travis during each Build:"
    echo "    \${DATA_DIR}/deps.sh      install dependencies"
    echo "    \${DATA_DIR}/build.sh     build your website"
    echo "    \${DATA_DIR}/deploy.sh    deploys the site"
    echo
    echo " Other Scripts:"
    echo "    \${DATA_DIR}/config.sh    your configuration information"
    echo
    echo " Other commands:"
    echo "    ⇒ gh-pages templates      list all installed templates"
    echo "    ⇒ gh-pages version        show version information"
    echo "    ⇒ gh-pages upgrade        upgrade gh-pages"
    echo
    echo " More Information:"
    echo "    You can easily install recommended templates using"
    echo "     ⇒ gh-pages recommended-templates"
    echo "    See https://github.com/GochoMugo/gh-pages for more"
    echo "      source code, feature requests and bugs"
    echo
  ;;
esac

}
