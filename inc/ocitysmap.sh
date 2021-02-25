#----------------------------------------------------
#
# Fetch OCitysMap from GitHub and configure it
#
#----------------------------------------------------

# install latest ocitysmap from git
cd /home/maposmatic
git clone --quiet ${OCITYSMAP_FORK_GIT}
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

