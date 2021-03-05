#----------------------------------------------------
#
# Install all required packages
#
#----------------------------------------------------

# uncomment this when using an old Ubuntu release no longer supported
# sed -i -e's/archive/old-releases/g' /etc/apt/sources.list


# we don't have "banner" installed yet at this point
echo "   ##    #####    #####          #####     ##     ####   #    #    ##     #### "
echo "  #  #   #    #     #            #    #   #  #   #    #  #   #    #  #   #    #"
echo " #    #  #    #     #            #    #  #    #  #       ####    #    #  #     "
echo " ######  #####      #            #####   ######  #       #  #    ######  #  ###"
echo " #    #  #          #            #       #    #  #    #  #   #   #    #  #    #"
echo " #    #  #          #            #       #    #   ####   #    #  #    #   #### "

# prevent configuration dialogs from popping up, we want fully automatic install
export DEBIAN_FRONTEND=noninteractive
echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections

# enable deb-src entries in apt sources list, needed for "apt build-dep"
sed -i -e 's/^#deb-src/deb-src/g' /etc/apt/sources.list
sed -i -e 's/^# deb-src/deb-src/g' /etc/apt/sources.list

# bring apt package database up to date
#
# recent Ubuntu base boxes seem to do perform some apt action on startup, too,
# causing lock errors here, so we try until success
until apt-get update --quiet=2
do
  sleep 3
done

# install needed extra deb pacakges
apt-get install --quiet=2 --assume-yes \
    apache2 \
    apt-src \
    asciidoctor \
    cabextract \
    cmake \
    coderay \
    curl \
    emacs \
    fonts-arkpandora \
    fonts-droid-fallback \
    fonts-khmeros \
    fonts-noto \
    fonts-noto-color-emoji \
    fonts-sil-padauk \
    fonts-sipa-arundina \
    fonts-taml-tscu \
    g++ \
    gir1.2-pango-1.0 \
    gir1.2-rsvg-2.0 \
    ccache \
    gdal-bin \
    gettext \
    git \
    imagemagick \
    libapache2-mod-fcgid \
    libapache2-mod-php \
    libapache2-mod-wsgi-py3 \
    libboost-python-dev \
    libbz2-dev \
    libcairo2-dev \
    libcgi-fast-perl \
    libgdal-dev \
    libkakasi2-dev \
    liblua5.3-dev \
    libmapnik3.0 \
    libmapnik-dev \
    libosmium2-dev \
    libpython3-dev \
    libutf8proc-dev \
    mapnik-utils \
    mc \
    mmv \
    munin \
    munin-node \
    munin-plugins-extra \
    osmium-tool \
    pandoc \
    php-cli \
    php-http-request2 \
    php7.4-xml \
    pngquant \
    poedit \
    postgis \
    postgresql \
    postgresql-contrib \
    postgresql-server-dev-all \
    python3-django \
    python3-future \
    python3-feedparser \
    python3-fiona \
    python3-gdal \
    python3-gi-cairo \
    python3-gpxpy \
    python3-lxml \
    python3-mapnik \
    python3-pip \
    python3-pil \
    python3-psycopg2 \
    python3-shapely \
    python3-slugify \
    python3-urllib3 \
    subversion \
    sysvbanner \
    texlive-extra-utils \
    texlive-latex-base \
    texlive-latex-recommended \
    time \
    transifex-client \
    tree \
    ttf-dejavu \
    ttf-mscorefonts-installer \
    ttf-unifont \
    unifont \
    unifont-bin \
    unzip \
    wkhtmltopdf \
    > /dev/null || exit 3

# this may cause crashes on fetching OSM diffs with osmium, so lets remove it for now
apt-get remove -y python3-apport > /dev/null

banner "python packages"
pip3 install \
     colour \
     django-cookie-law \
     django-maintenance-mode \
     fastnumbers \
     geoalchemy2 \
     geopy \
     natsort \
     osmium \
     pillow \
     pluginbase \
     pyproj \
     qrcode \
     sqlalchemy \
     "sqlalchemy-utils==0.35" \
     utm \
     > /dev/null || exit 3

# pip repository version of django-multiupload not compatible with Django 2.1+ yet
pip3 install -e git+https://github.com/Chive/django-multiupload.git#egg=multiupload > /dev/null || exit 3

# we can't uninstall the Ubuntu python3-pycairo package
# due to too many dependencies, but we need to make sure
# that we actually use the current pip pacakge to get
# support for PDF set_page_label() which the version
# of pycairo that comes with Ubuntu does not have yet
pip3 install --ignore-installed pycairo > /dev/null || exit 3


banner "ruby packages"
gem install --pre asciidoctor-pdf > /dev/null || exit 3


# install extra npm packages
banner "npm packages"
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
sudo apt-get install -y nodejs

npm config set loglevel warn

npm install -g carto > /dev/null || exit 3

