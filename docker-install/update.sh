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

modules="cmnctr ctzntkt"

# Update pixelhumain
echo "Update modules..."

if [ -d "${ph_dir}" ]; then
cd "${ph_dir}"
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

#create index mongo bash script
if [ -f "${MODULE_DIR}/${cmnctr_dir}/data/createIndexMongoDocker.sh" ];then
  echo "Create index mongo...";
  chmod +x "${MODULE_DIR}/${cmnctr_dir}/data/createIndexMongoDocker.sh"
  "${MODULE_DIR}/${cmnctr_dir}/data/createIndexMongoDocker.sh"
fi

