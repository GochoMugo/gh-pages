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
rm -rf gh-pages
git clone https://github.com/GochoMugo/gh-pages


echo "adding scripts to ${DEST}"
mkdir -p ${DEST}
cp -r gh-pages/gh-pages-lib gh-pages/gh-pages ${DEST}


echo ${PATH} | grep "${DEST}" > /dev/null || {
  echo "adding ${DEST} to PATH"
  echo '' >> ~/.bashrc
  echo '# added by gh-pages' >> ~/.bashrc
  echo 'export PATH='${DEST}':${PATH}' >> ~/.bashrc
  echo "    !! you may need to restart your terminal for the gh-pages to be found"
}

echo "finished installing!"
echo "it is recommended you install some useful templates using:"
echo "    ⇒ gh-pages recommended-templates"

