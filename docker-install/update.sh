#!/bin/bash

BASE_DIR="/code"
BASE_DIR_PH="${BASE_DIR}/pixelhumain/ph"

# Update pixelhumain
echo "Update repo modules..."
cd "${BASE_DIR}"
BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [[ "$BRANCH" != "master" ]]; then
  echo 'Aborting script branch not master';
  exit 1;
fi
git fetch origin
git pull origin master
git pull --recurse-submodules
git submodule update --recursive --remote

# Install Composer

if [ -f "/tmp/composer.phar" ];then
 rm "/tmp/composer.phar"
fi

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