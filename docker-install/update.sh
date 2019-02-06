#!/bin/bash

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
network_uri="https://gitlab.adullact.net/pixelhumain/network.git"
network_dir="network"
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

modules="cmnctr ctzntkt co2 network api dda news interop graph eco chat survey map onepage"


# Update pixelhumain
echo "Update modules..."

if [ -d "${ph_dir}" ]; then
cd "${ph_dir}"
git fetch origin
git pull origin master
cd ../..
fi

# Update modules
for mod in $modules
  do
    mod_uri=$(eval "echo \$${mod}_uri")
    mod_dir=$(eval "echo \$${mod}_dir")
    if [ -d "${MODULE_DIR}/$mod_dir" ]; then
      echo "Update ${mod_dir}"
      cd "${MODULE_DIR}/$mod_dir"
      git fetch origin
      git pull origin master
      cd ../../..
    fi
  done

echo "Import data"

echo "Import lists data..."
if [ -f "${MODULE_DIR}/${cmnctr_dir}/data/lists.json" ];then

mongo mongo/pixelhumain <<EOF
db.lists.dropIndexes();
db.lists.remove({});
EOF

mongoimport --host mongo --db pixelhumain --collection lists "${MODULE_DIR}/${cmnctr_dir}/data/lists.json" --jsonArray
fi

#Test cities.json
if [ -f "${MODULE_DIR}/${cmnctr_dir}/data/cities.json" ];then
 rm "${MODULE_DIR}/${cmnctr_dir}/data/cities.json"
fi

if [ -f "${MODULE_DIR}/${cmnctr_dir}/data/cities.json.zip" ];then

unzip "${MODULE_DIR}/${cmnctr_dir}/data/cities.json.zip" -d "${MODULE_DIR}/${cmnctr_dir}/data/"

#delete cities and delete all index cities
mongo mongo/pixelhumain <<EOF
db.cities.dropIndexes();
db.cities.remove({});
EOF

echo "Import cities data..."
#import cities
mongoimport --host mongo --db pixelhumain --collection cities "${MODULE_DIR}/${cmnctr_dir}/data/cities.json" --jsonArray
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
mongoimport --host mongo --db pixelhumain --collection zones "${MODULE_DIR}/${co2_dir}/data/zones.json" --jsonArray
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
mongoimport --host mongo --db pixelhumain --collection translate "${MODULE_DIR}/${co2_dir}/data/translate.json" --jsonArray
fi

#create index mongo bash script
if [ -f "${MODULE_DIR}/${cmnctr_dir}/data/createIndexMongoDocker.sh" ];then
  echo "Create index mongo...";
  chmod +x "${MODULE_DIR}/${cmnctr_dir}/data/createIndexMongoDocker.sh"
  "${MODULE_DIR}/${cmnctr_dir}/data/createIndexMongoDocker.sh"
fi
