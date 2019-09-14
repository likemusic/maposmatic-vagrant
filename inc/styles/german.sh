#----------------------------------------------------
#
# German CartoOsm style sheet - the current openstreetmap.de style
#
#----------------------------------------------------

cd /home/maposmatic/styles

git clone https://github.com/giggls/openstreetmap-carto-de.git

cd openstreetmap-carto-de
git checkout v4.22.0-l10n0

sed -i -e's/dbname: "osm"/dbname: "gis"/' project.mml
sed -i -e's/carto /carto -q /g' Makefile
make

for a in *.xml
do
    php /vagrant/files/postprocess-style.php $a
done

ln -s /home/maposmatic/shapefiles data

