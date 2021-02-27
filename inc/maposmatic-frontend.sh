#----------------------------------------------------
#
# MapOSMatic web frontend installation & configuration
#
#----------------------------------------------------

# get maposmatic web frontend
cd /home/maposmatic

if [[ -z "${MAPOSMATIC_FORK_BRANCH}" ]];
  then
    git clone --quiet ${MAPOSMATIC_FORK_GIT:-'https://github.com/hholzgra/maposmatic.git'}
  else
    git clone --quiet --branch ${MAPOSMATIC_FORK_BRANCH} ${MAPOSMATIC_FORK_GIT:-'https://github.com/hholzgra/maposmatic.git'}
fi

cd maposmatic
git checkout --quiet site-osm-baustelle


# install dependencies
(cd www/static; HOME=/root npm install)

# create needed directories and tweak permissions
mkdir -p logs rendering/results media

# copy config files
cp $FILEDIR/config-files/config.py scripts/config.py

export BBOX_MAXIMUM_LENGTH_IN_METERS=${BBOX_MAXIMUM_LENGTH_IN_METERS:-20000}

export PAPER_MIN_WITH_MM=${PAPER_MIN_WITH_MM:-100}
export PAPER_MAX_WITH_MM=${PAPER_MAX_WITH_MM:-2000}

export PAPER_MIN_HEIGHT_MM=${PAPER_MIN_HEIGHT_MM:-100}
export PAPER_MAX_HEIGHT_MM=${PAPER_MAX_HEIGHT_MM:-2000}

export MAPOSMATIC_FORK_URL=${MAPOSMATIC_FORK_URL:-'https://github.com/hholzgra/maposmatic'}
export OCITYSMAP_FORK_URL=${OCITYSMAP_FORK_URL:-'https://githib.com/hholzgra/ocitysmap'}

cat $FILEDIR/config-files/settings_local.py | envsubst > www/settings_local.py
cp $FILEDIR/config-files/maposmatic.wsgi www/maposmatic.wsgi

# copy static files from django applications
python3 manage.py collectstatic --no-input

# create import bounds information
cp /home/maposmatic/bounds/bbox.py www/settings_bounds.py
echo "MAX_BOUNDING_OUTER='''" >> www/settings_bounds.py
cat /home/maposmatic/bounds/outer.json >> www/settings_bounds.py
echo "'''" >> www/settings_bounds.py

# init MaposMatics housekeeping database
banner "Dj. Migration"
python3 manage.py makemigrations maposmatic
python3 manage.py migrate

# set up admin user
banner "Dj. Admin"
python3 manage.py shell -c "from django.contrib.auth.models import User; User.objects.create_superuser('admin', 'admin@example.com', 'secret')"

# set up translations
banner "Dj. Translate"
python3 manage.py compilemessages

(cd documentation; make 2>/dev/null; make install)

# fix directory ownerships
chown -R maposmatic /home/maposmatic
if test -f www/datastore.sqlite3
then
  chgrp www-data logs www www/datastore.sqlite3
  chmod   g+w    logs www www/datastore.sqlite3
fi
chgrp www-data media logs
chmod g+w media logs

# set up render daemon
cp $FILEDIR/systemd/maposmatic-render.service /etc/systemd/system
chmod 644 /etc/systemd/system/maposmatic-render.service
systemctl daemon-reload
systemctl enable maposmatic-render.service
systemctl start maposmatic-render.service

# set up web server
service apache2 stop
cp $FILEDIR/config-files/000-default.conf /etc/apache2/sites-available
service apache2 start

