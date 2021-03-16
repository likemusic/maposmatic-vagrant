#! /bin/bash

# --- DEPENDENT FROM .pbf --- #

banner "db import"
. $INCDIR/osm2pgsql-import.sh

banner "get bounds"
python3 $INCDIR/data-bounds.py $OSM_EXTRACT

banner "DEM setup"
. $INCDIR/elevation-data.sh

banner "start frontend"
. $INCDIR/maposmatic-frontend-after-import.sh

#----------------------------------------------------
#
# Set up various stylesheets
#
#----------------------------------------------------
mkdir /home/maposmatic/styles

for style in /vagrant/inc/styles/*.sh
do
  banner $(basename $style .sh)" style"
  . $style
done

for overlay in /vagrant/inc/overlays/*.sh
do
  banner $(basename $overlay .sh)" overlay"
  . $overlay
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
# munin monitoring
#
#----------------------------------------------------

banner "munin"

. $INCDIR/munin.sh


#----------------------------------------------------
#
# tests
#
#-----------------------------------------------------

banner "running tests"

. $INCDIR/testing.sh

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

