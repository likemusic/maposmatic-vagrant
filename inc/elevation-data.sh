#! /bin/bash

cd /home/maposmatic

mkdir -p elevation-data
cd elevation-data

echo "Downloading SRTM archive files"

mkdir -p srtm-data
cd srtm-data

mkdir -p $CACHEDIR/srtm-data

# extract bounding box data in bash array format
bbox=$(cat /home/maposmatic/bounds/bbox.bash)
#todo: stop process bbox if not exists

# create actaul bounding box bash array
eval b=$bbox

# create bounding box polygon WKT string
polygon="POLYGON((${b[1]} ${b[0]}, ${b[1]} ${b[2]}, ${b[3]} ${b[2]}, ${b[3]} ${b[0]}, ${b[1]} ${b[0]}))"

# now download all zones the import bounding box overlaps with
let cnt=$(psql gis --tuples-only --command="select zone from srtm_zones where ST_INTERSECTS(way, ST_GeomFromText('$polygon', 4326))" | wc -l)
let i=1;
for zone in $(psql gis --tuples-only --command="select zone from srtm_zones where ST_INTERSECTS(way, ST_GeomFromText('$polygon', 4326))"); do
  let percents=$i*100/$cnt

  echo " $percents% ($i/$cnt): zone $zone ... "

  CACHEFILE=$CACHEDIR/srtm-data/$zone.zip

  if [[ "$zone" == *\/* ]]; then
    SRTM_URL=http://viewfinderpanoramas.org/$zone.zip
  else
    SRTM_URL=http://viewfinderpanoramas.org/dem3/$zone.zip
  fi

  if ! test -f $CACHEFILE; then
    echo "  downloading ... "
    curl $SRTM_URL --create-dirs -o $CACHEFILE
  fi

  echo "  unzip ..."
  unzip -q $CACHEFILE
  i=$(($i+1))
done

cd ..

echo "SRTM hillshading for PisteMap"

mkdir -p srtm
cd srtm

let cnt=$(find /home/maposmatic/elevation-data/srtm-data/ -name "*.hgt" | sort | wc -l)
let i=1;

for file in $(find /home/maposmatic/elevation-data/srtm-data/ -name "*.hgt" | sort); do
  base=$(basename $file .hgt)

  let percents=$i*100/$cnt

  echo " $percents% ($i/$cnt): $base ... "

  echo "  gdal_translate ... "
  gdal_translate -q -of GTiff -co "TILED=YES" -a_srs "+proj=latlong" $file ${base}_adapted.tif

  echo "  gdalwarp ... "
  gdalwarp -q -multi -of GTiff -co "TILED=YES" -srcnodata 32767 -t_srs "+proj=merc +ellps=sphere +R=6378137 +a=6378137 +units=m" -rcs -order 3 -tr 30 30 -multi ${base}_adapted.tif ${base}_warped.tif

  echo "  gdaldem ... "
  gdaldem hillshade -q ${base}_warped.tif ${base}_hillshade.tif
  i=$(($i+1))
done

cd ..

echo "DEM data for OpenTopoMap"
mkdir -p dem
cd dem

# file taken from OpenTopoMap repository, which may not be installed at this point yet
cp /vagrant/files/relief_color_text_file.txt .

# fill empty spaces
let cnt=$(find /home/maposmatic/elevation-data/srtm-data/ -name "*.hgt" | sort | wc -l)
let i=1
for file in $(find /home/maposmatic/elevation-data/srtm-data -name "*.hgt" | sort); do
  let percents=$i*100/$cnt
  base=$(basename $file .hgt)

  echo " $percents% ($i/$cnt): $base ... "
  gdal_fillnodata.py -q $file $(basename $file).tif
  i=$(($i+1))
done

# merge all elevation data into one single large tiled file
echo "merging data into single file"
gdal_merge.py -n 32767 -co BIGTIFF=YES -co TILED=YES -co COMPRESS=LZW -co PREDICTOR=2 -o raw.tif *.hgt.tif -q

ln -s raw.tif dem-srtm.tiff
ln -s raw.tif dem_srtm.tiff

# convert to google mercator projection
interpolation=cubicspline
let cnt=4
let i=1
for r in 90 500 1000 5000; do
  let percents=$i*100/$cnt
  echo " $percents% ($i/$cnt): interpolation $r ... "
  gdalwarp -co BIGTIFF=YES -co TILED=YES -co COMPRESS=LZW -co PREDICTOR=2 -t_srs "+proj=merc +ellps=sphere +R=6378137 +a=6378137 +units=m" -r $interpolation -tr $r $r raw.tif warp-$r.tif -q
  interpolation=bilinear
done

# create colored reliefs for low zoom levels
echo "low color reliefs"
gdaldem color-relief -co COMPRESS=LZW -co PREDICTOR=2 -alpha warp-5000.tif relief_color_text_file.txt relief-5000.tif -q
gdaldem color-relief -co COMPRESS=LZW -co PREDICTOR=2 -alpha warp-500.tif relief_color_text_file.txt relief-500.tif -q

# create hillshading
echo "hillshading"
gdaldem hillshade -z 7 -compute_edges -co COMPRESS=JPEG warp-5000.tif hillshade-5000.tif -q
gdaldem hillshade -z 7 -compute_edges -co BIGTIFF=YES -co TILED=YES -co COMPRESS=JPEG warp-1000.tif hillshade-1000.tif -q
gdaldem hillshade -z 4 -compute_edges -co BIGTIFF=YES -co TILED=YES -co COMPRESS=JPEG warp-500.tif hillshade-500.tif -q
gdaldem hillshade -z 7 -combined -compute_edges -co compress=lzw -co predictor=2 -co bigtiff=yes warp-90.tif hillshade-90.tif -q
# TODO: not used? gdal_translate -co compress=JPEG -co bigtiff=yes -co tiled=yes hillshade-90.tif hillshade-90-jpeg.tif -q

# create contours shapefile and imports its data into the database
echo "gdal_contour"
gdal_contour -i 10 -a ele warp-90.tif contour.shp -q
echo "shp2pgsql"
shp2pgsql -a -g way -s 3857 contour.shp contours | psql --quiet contours

cd ..
