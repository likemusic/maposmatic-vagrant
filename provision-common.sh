#! /bin/bash

# --- INDEPENDENT FROM .pbf --- #

# For some strange reason I don't understand yet Vagrant
# seems to write "exit" to the provisioning scripts
# stdin stream. As this may confuse tools that optionally
# read from stdin (genenrate-xml.py in this case) we're
# draining stdin here as the first thing before doing
# anything else
if ! test -t 0
then
    cat > /dev/null
fi

#----------------------------------------------------
#
# putting some often used constants into variables
#
#----------------------------------------------------

FILEDIR=/vagrant/files
INCDIR=/vagrant/inc

if ${GROW_FS:-false}
then
. $INCDIR/resize-part-and-fs.sh
fi


if ${REPLACE_DNS:-false}
then
  . $INCDIR/replace-dns.sh
fi

if ${BIND_POSTGRESQL_DATA_DIRECTORY:-false}
then
  . $INCDIR/bind-postgresql-data-directory.sh
fi

if touch /vagrant/can_write_here
then
	CACHEDIR=/vagrant/cache
	rm /vagrant/can_write_here
else
	mkdir -p /home/cache
	chmod a+rwx /home/cache
	CACHEDIR=/home/cache
fi

mkdir -p $CACHEDIR

# Memory sharing schema: (work_mem=50MB) + ((maintenance_work_mem=15%) + (shared_buffers=1.5%) + (osm2pgsql cache=75%) + (keep for OS = 8.5%))

# store available memory size in KB in $MemAvailableInKB
let MemAvailableInKB=$(grep MemAvailable /proc/meminfo | sed -e's/kB//' -e's/ //g' -e's/MemAvailable://')
export MemAvailableInKB=$MemAvailableInKB

# store available memory size in MB in MemAvailableInMB
let MemAvailableInMB=$MemAvailableInKB/1024
export MemAvailableInMB=$MemAvailableInMB

#----------------------------------------------------
#
# check for an OSM PBF extract to import
#
# if there are more than one: take the first one found
# if there are none: exit
#
#----------------------------------------------------

export OSM_EXTRACT=$(ls /vagrant/*.pbf | head -1)

if test -f "$OSM_EXTRACT"
then
	echo "Using $OSM_EXTRACT for OSM data import"
else
	echo "No OSM .pbf data file found for import!"
	exit 3
fi



#----------------------------------------------------
#
# Vagrant/Virtualbox environment preparations
# (not really Ocitysmap specific yet)
#
#----------------------------------------------------

# override language settings
locale-gen en_US.UTF-8
localedef --force --inputfile=en_US --charmap=UTF-8 en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_ADDRESS=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
export LC_IDENTIFICATION=en_US.UTF-8
export LC_MEASUREMENT=en_US.UTF-8
export LC_MESSAGE=en_US.UTF-8
export LC_MONETARY=en_US.UTF-8
export LC_NAME=en_US.UTF-8
export LC_NUMERIC=en_US.UTF-8
export LC_PAPER=en_US.UTF-8
export LC_TELEPHONE=en_US.UTF-8
export LC_TIME=en_US.UTF-8

# silence curl and wget progress reports
# as these just flood the vagrant output in an unreadable way
# echo "--silent" > /root/.curlrc
# echo "quiet = on" > /root/.wgetrc

# To not freeze on network problems. For example when http://openptmap.org/f/symbols/ is not connectable.
# Default is 20.
echo "tries = 2" > ~/.wgetrc

# Default is 2min that is too long.
echo "connect-timeout = 10" >> ~/.wgetrc

# pre-seed compiler cache
if test -d $CACHEDIR/.ccache/
then
    cp -rn $CACHEDIR/.ccache/ ~/
else
    mkdir -p ~/.ccache
fi

# add "maposmatic" system user that will own the database and all locally installed stuff
#rm -rf /home/maposmatic/*
#mkdir -p /home/maposmatic
useradd --create-home maposmatic

# installing apt, pip and npm packages

. $INCDIR/install-packages.sh

# initial git configuration
. $INCDIR/git-setup.sh

# add host entry for gis-db
sed -ie 's/localhost/localhost gis-db/g' /etc/hosts

# no longer needed starting with yakkety
# . $INCDIR/mapnik-from-source.sh

banner "db setup"
. $INCDIR/database-setup.sh

banner "places db"
. $INCDIR/places-database.sh

# read SRTM 90m zone name -> area mapping table
echo "Importing SRTM zone database"
sudo -u maposmatic psql gis < /vagrant/files/database/db_dumps/srtm_zones.sql > /dev/null

# set up countours database and table schema
echo "create contour db"
sudo -u maposmatic psql --quiet gis </vagrant/files/database/db_dumps/contours_schema.sql

banner "db l10n"
. $INCDIR/from-source/mapnik-german-l10n.sh

banner "building osgende"
. $INCDIR/from-source/osgende.sh

banner "building osm2pgsql"
. $INCDIR/from-source/osm2pgsql-build.sh

banner "building phyghtmap" # needed by OpenTopoMap
. $INCDIR/from-source/phyghtmap.sh

banner "renderer setup"
. $INCDIR/ocitysmap.sh

banner "locales"
. $INCDIR/locales.sh

banner "shapefiles"
. $INCDIR/get-shapefiles.sh
cp /vagrant/files/systemd/shapefile-update.* /etc/systemd/system
systemctl daemon-reload


#----------------------------------------------------
#
# Setting up Django fronted
#
#----------------------------------------------------

banner "django frontend"

. $INCDIR/apache-global-config.sh
. $INCDIR/maposmatic-frontend.sh


#----------------------------------------------------
#
# Setting up "Umgebungsplaene" alternative frontend
#
#----------------------------------------------------

banner "umgebungsplaene"

. $INCDIR/umgebungsplaene.sh