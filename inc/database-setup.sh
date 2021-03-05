#----------------------------------------------------
#
# Set up PostgreSQL and PostGIS
#
#----------------------------------------------------

# config tweaks
# TODO: how to auto-detect correct conf include dir?
# Set memory config according to https://osm2pgsql.org/doc/manual.html#tuning-the-postgresql-server

# Set work_mem to 50MB
let WorkMemInMB=50

# For maintenance_work_mem set 15% of shared memory.
let MaintenanceWorkMemInPercents=15
let MaintenanceWorkMemInMB=$MemAvailableInMB*$MaintenanceWorkMemInPercents/100

# For shared_buffers set 2% of shared memory.
let SharedBuffersInPercents=2
let SharedBuffersInMB=$MemAvailableInMB*$SharedBuffersInPercents/100

sed -e"s/#shared_buffers#/$SharedBuffersInMB/g" -e"s/#work_mem#/$WorkMemInMB/g" -e"s/#maintenance_work_mem#/$MaintenanceWorkMemInMB/g" </vagrant/files/config-files/postgresql-extra.conf >/etc/postgresql/12/main/conf.d/postgresql-extra.conf
systemctl restart postgresql

# add "gis" database users
sudo --user=postgres createuser --superuser --no-createdb --no-createrole maposmatic
sudo -u postgres createuser -g maposmatic root
sudo -u postgres createuser -g maposmatic vagrant


# creade database for osm2pgsql import
sudo --user=postgres createdb --encoding=UTF8 --locale=en_US.UTF-8 --template=template0 --owner=maposmatic gis

# set up PostGIS for osm2pgsql database
sudo --user=postgres psql --dbname=gis --command="CREATE EXTENSION postgis"
sudo --user=postgres psql --dbname=gis --command="ALTER TABLE geometry_columns OWNER TO maposmatic"
sudo --user=postgres psql --dbname=gis --command="ALTER TABLE spatial_ref_sys OWNER TO maposmatic"
sudo --user=postgres psql --dbname=gis --command="CREATE EXTENSION postgis_sfcgal"

# enable hstore extension
sudo --user=postgres psql --dbname=gis --command="CREATE EXTENSION hstore"

# set up maposmatic admin table
sudo --user=maposmatic psql --dbname=gis --command="CREATE TABLE maposmatic_admin (last_update timestamp)"
sudo --user=maposmatic psql --dbname=gis --command="INSERT INTO maposmatic_admin VALUES ('1970-01-01 00:00:00')"

# creade database for maposmatic
sudo --user=postgres createdb --encoding=UTF8 --locale=en_US.UTF-8 --template=template0 --owner=maposmatic maposmatic

# set password for gis database user
sudo --user=maposmatic psql --dbname=postgres --command="ALTER USER maposmatic WITH PASSWORD 'secret';"

