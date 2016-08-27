# WIP

# auto install ubuntu

# options stop container
docker stop $(docker ps -a -q)
# options delete container
docker rm $(docker ps -a -q)
# options delete images
docker rmi $(docker images -q)

# auto install : docker , docker-compose and communecter
wget -O - https://gist.githubusercontent.com/aboire/4c83ff97026b1a4fabaada09950b2fc8/raw/install.sh| bash

# updating the user's permissions to edit files
cd ~/pixelhumain-docker
sudo chown -R ${USER:=$(/usr/bin/id -run)}:$USER code/pixelhumain/
sudo chown -R ${USER:=$(/usr/bin/id -run)}:$USER code/modules/

# Initial setup
* 0 Clone this repository
```
git clone https://github.com/pixelhumain/docker pixelhumain-docker
```
* 1 Create a folder *code* *code/data/db* that will be the source directory inside pixelhumain-docker
```
mkdir -p code/data/db
```
* 2 Put your source file in the *code* directory:
    - see https://github.com/pixelhumain/pixelhumain/blob/master/README.md
    - use the docker image provided below
    - Your VCS / IDE / ...
* 3 Start the containers using:
```
docker-compose -f docker-compose.yml up
```
* 4 Access to the test service through http://127.0.0.1:5080/index.php/test
* 5 Access to communecter through http://127.0.0.1:5080/
* 6 You can modify your sources code with your prefered editor in the code directory

# Layout overview

```
|-- code
    |-- modules
        |-- communecter
        |-- citizenToolKit
    |-- pixelhumain
        |-- ph
        |-- [...]
|-- docker-install
    |-- install-conf
    |-- [...]
|-- docker-front
[...]
```

# Basic setup and data with the docker image
  For an initial setup you'll need to init MongoDB, configurations, etc (see
  communecter install guide for more details)
  An easy to use image with an install script is provided through the docker
  imager « ph » and can be used with this command
```
docker-compose -f docker-compose.yml -f docker-compose.install.yml run ph install
```
  The install script fetch every modules in the pixelhumain guide, create directories
  and populate some data like cities, ...

# Updating Dockers images
Useful commands:

Start services
```
docker-compose -f docker-compose.yml up
```
Shutdown gracefuly services
```
docker-compose -f docker-compose.yml down
```
Re-build images after modifications of docker files
```
docker-compose -f docker-compose.yml build
#docker-compose -f docker-compose.yml -f docker-compose.install.yml build ph
```
Install base sources codes and populates some data
```
docker-compose -f docker-compose.yml -f docker-compose.install.yml run ph install
```
See log from nginx
```
docker-compose -f docker-compose.yml -f docker-compose.install.yml run ph supervisorctl tail nginx
docker-compose -f docker-compose.yml -f docker-compose.install.yml run ph supervisorctl tail nginx stderr
```
