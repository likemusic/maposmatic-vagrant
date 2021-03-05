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
#git checkout --quiet site-osm-baustelle


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
