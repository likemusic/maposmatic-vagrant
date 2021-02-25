#----------------------------------------------------
#
# Fetch OCitysMap from GitHub and configure it
#
#----------------------------------------------------

# install latest ocitysmap from git
cd /home/maposmatic

if [[ -z "${OCITYSMAP_FORK_BRANCH}" ]];
  then
    git clone --quiet --branch ${OCITYSMAP_FORK_BRANCH} ${OCITYSMAP_FORK_GIT}
  else
    git clone --quiet ${OCITYSMAP_FORK_GIT}
fi

cd ocitysmap

# fetch submodules so that all icon sets are actually installed
git submodule init
git submodule update

# compile all translation files
./i18n.py --compile-mo

# make sure the cmdline render script is executable
chmod a+x render.py

# install the command line wrapper script in $PATH
cp /vagrant/files/config-files/ocitysmap-command.sh /usr/local/bin/ocitysmap
chmod a+x /usr/local/bin/ocitysmap

cd ..

