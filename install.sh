#
# Installation Script
#


# stop on error
set -e


# script variables
DEST=${HOME}/Bin


echo "changing directory to /tmp"
cd /tmp


echo "cloning the repository"
git clone https://github.com/GochoMugo/gh-pages


echo "adding scripts to ${DEST}"
mkdir -p ${DEST}
cp -r gh-pages/gh-pages-lib gh-pages/gh-pages ${DEST}


echo ${PATH} | grep "${DEST}" > /dev/null || {
  echo "adding ${DEST} to PATH"
  echo "export PATH=${DEST}:${PATH}" >> ~/.bashrc
}

