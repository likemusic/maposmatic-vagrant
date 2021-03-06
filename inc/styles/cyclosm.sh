#! /bin/bash

cd /home/maposmatic/styles

git clone --quiet https://github.com/cyclosm/cyclosm-cartocss-style
cd cyclosm-cartocss-style

git checkout v0.3.7

ln -s /home/maposmatic/shapefiles data

cd dem
for hillshade in /home/maposmatic/styles/OpenTopoMap/mapnik/dem/hillshade*
do
    ln -s $hillshade .
done
cd ..
		 
sed -e 's/dbname: "osm"/dbname: "gis"/g' \
    -e 's/http:\/\/osmdata.openstreetmap.de\/download\/simplified-land-polygons-complete-3857.zip/.\/data\/simplified-land-polygons-complete-3857\/simplified_land_polygons.shp/g' \
    -e 's/http:\/\/osmdata.openstreetmap.de\/download\/land-polygons-split-3857.zip/.\/data\/land-polygons-split-3857\/land_polygons.shp/g' \
    -e 's/layer~/layer::text~/g' \
    < project.mml > cyclosm.mml

carto -a $(mapnik-config -v) --quiet cyclosm.mml > cyclosm.xml
php /vagrant/files/tools/postprocess-style.php cyclosm.xml

# style expects contours table under a different name, and ele column with different type
sudo -u maposmatic psql contours -c "create view planet_osm_line as select gid, id, ele::int as ele, way from contours;"

