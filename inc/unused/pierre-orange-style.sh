#----------------------------------------------------
#
# MapOSMatic Printable stylesheet
#
#----------------------------------------------------

cd /home/maposmatic/styles

# we need to add the MapOSMatic specific
# symbols to the "old" MapnikOSM symbol set
cp ../ocitysmap/stylesheet/maposmatic-printable/symbols/* mapnik2-osm/symbols/

# configure the actual stylesheet
cd ../ocitysmap/stylesheet/pierre-orange

/vagrant/files/tools/generate_xml.py \
       --dbname gis \
       --host 'localhost' \
       --user maposmatic \
       --port 5432 \
       --password 'secret' \
       --world_boundaries /home/maposmatic/shapefiles/world_boundaries \
       --symbols /home/maposmatic/ocitysmap/stylesheet/maposmatic-printable/symbols

