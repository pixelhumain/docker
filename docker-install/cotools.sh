#!/bin/bash

asciiart

## Options:
##     -h, --help               aide
##         --install            install
##         --update             update
##         --update-data        importe ou reimporte base data
##         --add-cron           Ajout de la tache cron pour l'envoi des mails
##         --emailvalid=VALUE   valide compte user avec le mail


source easyoptions || exit # Bash implementation, slower

BASE_DIR="/code"
BASE_DIR_PH="${BASE_DIR}/pixelhumain/ph"
MODULE_DIR="/code/modules"
ph_dir="${BASE_DIR}/pixelhumain"
co2_dir="co2"

[[ -n "$install"  ]] && /usr/bin/install
[[ -n "$update"  ]] && /usr/bin/update
[[ -n "$emailvalid"   ]] && echo "Option specified: --emailvalid is $emailvalid"

if [ -n "$emailvalid" ]
then
EVAL="db.citoyens.update({\"email\":\"$emailvalid\"},{\"\$unset\" :{\"roles.tobeactivated\":\"\"}})"
echo $EVAL | mongo mongo/pixelhumain --quiet
fi

if [ -n "$update_data" ]
then

echo "Import data"

echo "Import lists data..."
if [ -f "${MODULE_DIR}/${co2_dir}/data/lists.json" ];
then
mongo mongo/pixelhumain <<EOF
db.lists.dropIndexes();
db.lists.remove({});
EOF
mongoimport --host mongo --db pixelhumain -u pixelhumain -p pixelhumain --collection lists "${MODULE_DIR}/${co2_dir}/data/lists.json" --jsonArray
fi

#Test cities.json
if [ -e "${MODULE_DIR}/${co2_dir}/data/cities.json" ];
then
 rm "${MODULE_DIR}/${co2_dir}/data/cities.json"
fi

if [ -f "${MODULE_DIR}/${co2_dir}/data/cities.json.zip" ];
then

unzip "${MODULE_DIR}/${co2_dir}/data/cities.json.zip" -d "${MODULE_DIR}/${co2_dir}/data/"

#delete cities and delete all index cities
mongo mongo/pixelhumain <<EOF
db.cities.dropIndexes();
db.cities.remove({});
EOF

echo "Import cities data..."
#import cities
mongoimport --host mongo --db pixelhumain -u pixelhumain -p pixelhumain --collection cities "${MODULE_DIR}/${co2_dir}/data/cities.json"
fi

#Test zones.json
if [ -f "${MODULE_DIR}/${co2_dir}/data/zones.json" ];
then
 rm "${MODULE_DIR}/${co2_dir}/data/zones.json"
fi

if [ -f "${MODULE_DIR}/${co2_dir}/data/zones.json.zip" ];
then

unzip "${MODULE_DIR}/${co2_dir}/data/zones.json.zip" -d "${MODULE_DIR}/${co2_dir}/data/"

#delete cities and delete all index cities
mongo mongo/pixelhumain <<EOF
db.zones.dropIndexes();
db.zones.remove({});
EOF

echo "Import zones data..."
#import zones
mongoimport --host mongo --db pixelhumain -u pixelhumain -p pixelhumain --collection zones "${MODULE_DIR}/${co2_dir}/data/zones.json"
fi

#Test translate.json
if [ -f "${MODULE_DIR}/${co2_dir}/data/translate.json" ];
then
 rm "${MODULE_DIR}/${co2_dir}/data/translate.json"
fi

if [ -f "${MODULE_DIR}/${co2_dir}/data/translate.json.zip" ];
then

unzip "${MODULE_DIR}/${co2_dir}/data/translate.json.zip" -d "${MODULE_DIR}/${co2_dir}/data/"

#delete cities and delete all index cities
mongo mongo/pixelhumain <<EOF
db.translate.dropIndexes();
db.translate.remove({});
EOF

echo "Import translate data..."
#import cities
mongoimport --host mongo --db pixelhumain -u pixelhumain -p pixelhumain --collection translate "${MODULE_DIR}/${co2_dir}/data/translate.json"
fi

#create index mongo bash script
if [ -f "${MODULE_DIR}/${co2_dir}/data/createIndexMongoDocker.sh" ];
then
  echo "Create index mongo...";
  chmod +x "${MODULE_DIR}/${co2_dir}/data/createIndexMongoDocker.sh"
  "${MODULE_DIR}/${co2_dir}/data/createIndexMongoDocker.sh"
fi

fi


if [ -n "$add_cron" ]
then
echo "Ajout de la tache cron pour l'envoi des mails"
#Ajout de la tache cron pour l'envoi des mails
#Adding sent mail job in cron
cron="*/10 * * * * curl http://front/communecter/test/docron"
(crontab -u root -l; echo "$cron" ) | crontab -u root -

#Redemarrage de cron
#Restarting cron
service cron restart
echo "N oubliez pas de modifier le fichier $BASE_DIR_PH/protected/config/paramsconfig.php avec vos parametres SMTP et de vous rendre sur http://localhost:5080/communecter/test/docron pour lancer le processus d envoi de mail"
fi
