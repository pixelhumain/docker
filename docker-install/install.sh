#!/bin/bash

BASE_DIR="/code"
BASE_DIR_PH="${BASE_DIR}/pixelhumain/ph"
MODULE_DIR="/code/modules"

ph_uri="https://github.com/pixelhumain/pixelhumain.git"
ph_dir="${BASE_DIR}/pixelhumain"

cmnctr_uri="https://github.com/pixelhumain/communecter.git"
cmnctr_dir="communecter"
ctzntkt_uri="https://github.com/pixelhumain/citizenToolkit.git"
ctzntkt_dir="citizenToolKit"
ctdt_uri="https://github.com/pixelhumain/cityData.git"
ctdt_dir="cityData"
pndt_uri="https://github.com/pixelhumain/opendata.git"
pndt_dir="opendata"

modules="cmnctr ctzntkt ctdt pndt"

# Install pixelhumain
git clone "$ph_uri" "$ph_dir"

# Setup directories
mkdir -vp /code/{modules,pixelhumain/ph/{assets,protected/runtime}}

# Install missing modules
for mod in $modules
  do
    mod_uri=$(eval "echo \$${mod}_uri")
    mod_dir=$(eval "echo \$${mod}_dir")
    if [ -d "${MODULE_DIR}/$mod_dir" ]; then
      continue
    fi
    echo "Installing ${mod_dir}"
    git clone "$mod_uri" "${MODULE_DIR}/$mod_dir" || exit 1
  done
 
# Setup MongoDB

echo "Setting up credentials"

mongo mongo/pixelhumain <<EOF
db.createUser({ user: 'pixelhumain', pwd: 'pixelhumain', roles: [ { role: "readWrite", db: "pixelhumain" } ] });
EOF

mongo mongo/pixelhumaintest <<EOF
db.createUser({ user: 'pixelhumain', pwd: 'pixelhumain', roles: [ { role: "readWrite", db: "pixelhumain" } ] });
EOF

# Setup configuration for MongoDB
# Overwrite $dbconfig variable by appending to the end
# TODO Don't add endlessly

cat >> "${BASE_DIR_PH}/protected/config/dbconfig.php" <<EOF

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

echo "Installing composer" # No package manager available...

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

echo "Setting up with Composer"

cd "${BASE_DIR_PH}"
/tmp/composer.phar config -g "secure-http" false
/tmp/composer.phar update
/tmp/composer.phar install 

# TODO: Don't import endlessly
mongoimport --host mongo --db pixelhumain --collection lists /code/modules/communecter/data/lists.json --jsonArray
unzip /code/modules/communecter/data/cities.json.zip -d /code/modules/communecter/data/
mongoimport --host mongo --db pixelhumain --collection cities /code/modules/communecter/data/cities.json --jsonArray
