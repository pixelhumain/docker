#!/bin/sh

BASE_DIR=/code/pixelhumain
BASE_DIR_PH="${BASE_DIR}/ph"

# Setup MongoDB

echo "Installing MongoDB"

## Install mongodb 3.2
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927 && \
    echo "deb http://repo.mongodb.org/apt/debian jessie/mongodb-org/3.2 main" | \
    tee /etc/apt/sources.list.d/mongodb-org-3.2.list && \
    apt-get update && apt-get install --force-yes -y mongodb-org-shell || exit 1 # --force-yes due to a key problem #TODO

echo "Setting up credentials"

mongo mongo/pixelhumain <<EOF
db.createUser({ user: 'pixelhumain', pwd: 'pixelhumain', roles: [ { role: "readWrite", db: "pixelhumain" } ] });
EOF

mongo mongo/pixelhumaintest <<EOF
db.createUser({ user: 'pixelhumain', pwd: 'pixelhumain', roles: [ { role: "readWrite", db: "pixelhumain" } ] });
EOF

# Setup configuration for MongoDB
# Overwrite $dbconfig variable by appending to the end

cat >> "${BASE_DIR}/ph/protected/config/dbconfig.php" <<EOF

\$dbconfig = array(
    'class' => 'mongoYii.EMongoClient',
    'server' => 'mongodb://mongo:27017/',
    'db' => 'pixelhumain',
);
\$dbconfigtest = array(
    'class' => 'mongoYii.EMongoClient',
    'server' => 'mongodb://mongo:27017/',
    'db' => 'pixelhumaintest',
);
EOF

# Install Composer

echo "Installing composer"

EXPECTED_SIGNATURE=$(wget https://composer.github.io/installer.sig -O - -q)
cd /tmp
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
ACTUAL_SIGNATURE=$(php -r "echo hash_file('SHA384', 'composer-setup.php');")

if [ "$EXPECTED_SIGNATURE" = "$ACTUAL_SIGNATURE" ]
then
    php composer-setup.php --quiet
    rm composer-setup.php
else
    >&2 echo 'ERROR: Invalid installer signature'
    rm composer-setup.php
    exit 1
fi

# Setup directory

echo "Setting up directories"

mkdir -v "${BASE_DIR_PH}/protected/runtime"
mkdir -v "${BASE_DIR_PH}/assets"

echo "Setting up with Composer"

cd "${BASE_DIR_PH}"
/tmp/composer.phar config -g "secure-http" false
/tmp/composer.phar update
/tmp/composer.phar install 
