# create import bounds information
cd /home/maposmatic/maposmatic
cp /home/maposmatic/bounds/bbox.py www/settings_bounds.py
echo "MAX_BOUNDING_OUTER='''" >> www/settings_bounds.py
cat /home/maposmatic/bounds/outer.json >> www/settings_bounds.py
echo "'''" >> www/settings_bounds.py

# DON'T SURE ABOUT DEPENDENCIES BETWEEN COMMANDS BELOW, SO KEEP IT THERE.
# IF YOU SURE THAT SOME OF COMMANDS BELOW COULD BE DONE BEFORE IMPORT OSM PLEASE MAKE PR.

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
