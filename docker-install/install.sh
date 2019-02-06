#!/bin/bash

asciiart

BASE_DIR="/code"
BASE_DIR_PH="${BASE_DIR}/pixelhumain/ph"
MODULE_DIR="/code/modules"

ph_uri="https://gitlab.adullact.net/pixelhumain/pixelhumain.git"
ph_dir="${BASE_DIR}/pixelhumain"

cmnctr_uri="https://gitlab.adullact.net/pixelhumain/communecter.git"
cmnctr_dir="communecter"
co2_uri="https://gitlab.adullact.net/pixelhumain/co2.git"
co2_dir="co2"
api_uri="https://gitlab.adullact.net/pixelhumain/api.git"
api_dir="api"
#network_uri="https://gitlab.adullact.net/pixelhumain/network.git"
#network_dir="network"
ctzntkt_uri="https://gitlab.adullact.net/pixelhumain/citizenToolkit.git"
ctzntkt_dir="citizenToolKit"

dda_uri="https://gitlab.adullact.net/pixelhumain/dda.git"
dda_dir="dda"
news_uri="https://gitlab.adullact.net/pixelhumain/news.git"
news_dir="news"
graph_uri="https://gitlab.adullact.net/pixelhumain/graph.git"
graph_dir="graph"
interop_uri="https://gitlab.adullact.net/pixelhumain/interop.git"
interop_dir="interop"
eco_uri="https://gitlab.adullact.net/pixelhumain/eco.git"
eco_dir="eco"
chat_uri="https://gitlab.adullact.net/pixelhumain/chat.git"
chat_dir="chat"
survey_uri="https://gitlab.adullact.net/pixelhumain/survey.git"
survey_dir="survey"
map_uri="https://gitlab.adullact.net/pixelhumain/map.git"
map_dir="map"
onepage_uri="https://gitlab.adullact.net/pixelhumain/onepage.git"
onepage_dir="onepage"

#git clone https://gitlab.adullact.net/pixelhumain/classifieds.git
#git clone https://gitlab.adullact.net/pixelhumain/ressources.git
#git clone https://gitlab.adullact.net/pixelhumain/places.git
#git clone https://gitlab.adullact.net/pixelhumain/learn.git
#git clone https://gitlab.adullact.net/pixelhumain/cotools.git

modules="cmnctr ctzntkt co2 api dda news interop graph eco chat survey map onepage"

# Install pixelhumain
if [ -d "${ph_dir}" ]
then
 echo "Déja cloner"
else
git clone "$ph_uri" "$ph_dir"
fi

# Setup directories
mkdir -vp /code/{modules,pixelhumain/ph/{assets,upload,protected/runtime}}

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

#lien
ln -s "${MODULE_DIR}/co2" "${MODULE_DIR}/network"

# Setup MongoDB

echo "Setting up credentials"

mongo mongo/pixelhumain <<EOF
db.createUser({ user: 'pixelhumain', pwd: 'pixelhumain', roles: [ { role: "readWrite", db: "pixelhumain" } ] });
EOF

mongo mongo/pixelhumaintest <<EOF
db.createUser({ user: 'pixelhumain', pwd: 'pixelhumain', roles: [ { role: "readWrite", db: "pixelhumain" } ] });
EOF

# Setup configuration for MongoDB
if [ -f "${BASE_DIR_PH}/protected/config/dbconfig.php" ]
then
echo "configuration mongodb déja présente : $BASE_DIR_PH/protected/config/dbconfig.php"
else
  #mv ${BASE_DIR_PH}/protected/config/dbconfig.exemple.php ${BASE_DIR_PH}/protected/config/protected/config/dbconfig.php
  cat > "${BASE_DIR_PH}/protected/config/dbconfig.php" <<EOF
  <?php

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
fi

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

echo "Import data"

echo "Import lists data..."
if [ -f "${MODULE_DIR}/${co2_dir}/data/lists.json" ];then

mongo mongo/pixelhumain <<EOF
db.lists.dropIndexes();
db.lists.remove({});
EOF

mongoimport --host mongo --db pixelhumain --collection lists "${MODULE_DIR}/${co2_dir}/data/lists.json" --jsonArray
fi

#Test cities.json
if [ -f "${MODULE_DIR}/${co2_dir}/data/cities.json" ];then
 rm "${MODULE_DIR}/${co2_dir}/data/cities.json"
fi

if [ -f "${MODULE_DIR}/${co2_dir}/data/cities.json.zip" ];then

unzip "${MODULE_DIR}/${co2_dir}/data/cities.json.zip" -d "${MODULE_DIR}/${co2_dir}/data/"

#delete cities and delete all index cities
mongo mongo/pixelhumain <<EOF
db.cities.dropIndexes();
db.cities.remove({});
EOF

echo "Import cities data..."
#import cities
mongoimport --host mongo --db pixelhumain --collection cities "${MODULE_DIR}/${co2_dir}/data/cities.json"
fi

#Test zones.json
if [ -f "${MODULE_DIR}/${co2_dir}/data/zones.json" ];then
 rm "${MODULE_DIR}/${co2_dir}/data/zones.json"
fi

if [ -f "${MODULE_DIR}/${co2_dir}/data/zones.json.zip" ];then

unzip "${MODULE_DIR}/${co2_dir}/data/zones.json.zip" -d "${MODULE_DIR}/${co2_dir}/data/"

#delete cities and delete all index cities
mongo mongo/pixelhumain <<EOF
db.zones.dropIndexes();
db.zones.remove({});
EOF

echo "Import zones data..."
#import zones
mongoimport --host mongo --db pixelhumain --collection zones "${MODULE_DIR}/${co2_dir}/data/zones.json"
fi

#Test translate.json
if [ -f "${MODULE_DIR}/${co2_dir}/data/translate.json" ];then
 rm "${MODULE_DIR}/${co2_dir}/data/translate.json"
fi

if [ -f "${MODULE_DIR}/${co2_dir}/data/translate.json.zip" ];then

unzip "${MODULE_DIR}/${co2_dir}/data/translate.json.zip" -d "${MODULE_DIR}/${co2_dir}/data/"

#delete cities and delete all index cities
mongo mongo/pixelhumain <<EOF
db.translate.dropIndexes();
db.translate.remove({});
EOF

echo "Import translate data..."
#import cities
mongoimport --host mongo --db pixelhumain --collection translate "${MODULE_DIR}/${co2_dir}/data/translate.json"
fi

#delete cities and delete all index cities
mongo mongo/pixelhumain <<EOF
db.createCollection("applications")
db.applications.insert({     "_id" : ObjectId("59f1920bc30f30536124355d"),     "name" : "DEV Config",     "key" : "devParams",     "mangoPay" : {         "ClientId" : "communecter",         "ClientPassword" : "xxxx",         "TemporaryFolder" : "../../tmp"     } } )
db.applications.insert({     "_id" : ObjectId("59f1920bc30f30536124355e"),     "name" : "PROD Config",     "key" : "prodParams",     "mangoPay" : {         "ClientId" : "communecter",         "ClientPassword" : "xxxx",         "TemporaryFolder" : "../../tmp"     } } )
EOF

#create index mongo bash script
if [ -f "${MODULE_DIR}/${co2_dir}/data/createIndexMongoDocker.sh" ];then
  echo "Create index mongo...";
  chmod +x "${MODULE_DIR}/${co2_dir}/data/createIndexMongoDocker.sh"
  "${MODULE_DIR}/${co2_dir}/data/createIndexMongoDocker.sh"
fi

echo "Communecte est maintenant disponible depuis http://localhost:5080"

echo "pour valider un user sans regler l'envoie d'email vous pouvez le valider avec : docker-compose -f docker-compose.yml -f docker-compose.install.yml run ph cotools --emailvalid=email@example.com "
echo "vous pouvez ajouter le cron pour les email avec : docker-compose -f docker-compose.yml -f docker-compose.install.yml run ph cotools --add-cron "

echo "pour pouvoir editer le code sur votre machine ou serveur :"
echo "sudo chown -R \${USER:=\$(/usr/bin/id -run)}:\$USER code/pixelhumain/"
echo "sudo chown -R \${USER:=\$(/usr/bin/id -run)}:\$USER code/modules/"
echo "sudo chown -R \${USER:=\$(/usr/bin/id -run)}:\$USER code/log/"

echo "les logs nginx ce trouve dans code/log"
