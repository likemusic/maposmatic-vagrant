#----------------------------------------------------
#
# putting some often used constants into variables
#
#----------------------------------------------------

FILEDIR=/vagrant/files
INCDIR=/vagrant/inc

if touch /vagrant/can_write_here
then
	CACHEDIR=/vagrant/cache
	rm /vagrant/can_write_here
else
	CACHEDIR=/home/cache
fi

mkdir -p $CACHEDIR
chmod a+w $CACHEDIR
exit

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
localedef -v -c -i en_US -f UTF-8 en_US.UTF-8
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
echo "--silent" > /root/.curlrc
echo "quiet = on" > /root/.wgetrc

# pre-seed compiler cache
if test -d $CACHEDIR/.ccache/
then
    cp -rn $CACHEDIR/.ccache/ ~/
else
    mkdir -p ~/.ccache
fi


# installing apt, pip and npm packages

. $INCDIR/install-packages.sh

# initial git configuration
. $INCDIR/git-setup.sh

# add "maposmatic" system user that will own the database and all locally installed stuff
useradd --create-home maposmatic

# add host entry for gis-db
sed -ie 's/localhost/localhost gis-db/g' /etc/hosts

# no longer needed starting with yakkety
# . $INCDIR/mapnik-from-source.sh

banner "db setup"
. $INCDIR/database-setup.sh

banner "places db"
. $INCDIR/places-database.sh

banner "db l10n"
. $INCDIR/mapnik-german-l10n.sh

banner "building osgende"
. $INCDIR/osgende.sh

# banner "building osm2pgsql"
# . $INCDIR/osm2pgsql-build.sh
   
banner "db import" 
. $INCDIR/osm2pgsql-import.sh

banner "renderer setup"
. $INCDIR/ocitysmap.sh

banner "locales"
. $INCDIR/locales.sh

#----------------------------------------------------
#
# Set up various stylesheets 
#
#----------------------------------------------------

banner "shapefiles"
. $INCDIR/get-shapefiles.sh

mkdir /home/maposmatic/styles

styles="
  osm-carto 
  alternative-colors
  osm-mapnik 
  maposmatic 
  hikebike 
  humanitarian
  mapquest
  german
  french
  belgian
  ardenne
  swiss
  pistemap
  osmbright
  opentopomap
  openriverboat
  veloroad
  cyclosm
  blossom
  pandonia
  routexl
  pencil
  spacestation
  toner
  empty
"

for style in $styles
do
  banner "$style style"
  . $INCDIR/$style-style.sh
done

overlays="
  golf
  fire
  maxspeed
  gaslight
  ptmap
  schwarzkarte
  contour
  openrailway
  waymarked
  resiliency
"

for overlay in $overlays
do
  banner "$overlay overlay"
  . $INCDIR/$overlay-overlay.sh
done

#----------------------------------------------------
#
# Postprocess all generated style sheets
#
#----------------------------------------------------

banner "postprocessing styles"

. $INCDIR/ocitysmap-conf.sh

# cd /home/maposmatic/styles
# find . -name osm.xml | xargs \
#    sed -i -e's/background-color="#......"/background-color="#FFFFFF"/g'

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


#----------------------------------------------------
#
# tests
#
#-----------------------------------------------------

banner "running tests"

cd /vagrant/test
chmod a+w .
rm -f test-* thumbnails/test-*
./run-tests.sh

#----------------------------------------------------
#
# cleanup
#
#-----------------------------------------------------

banner "cleanup"

# some necessary security tweaks
. $INCDIR/security-quirks.sh

# write back compiler cache
cp -rn /root/.ccache $CACHEDIR

