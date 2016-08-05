# WIP

# Initial setup
* 0 Clone this repository
```
git clone https://github.com/pixelhumain/docker pixelhumain-docker
```
* 1 Create a folder *code* that will be the source directory inside pixelhumain-docker
```
mkdir code
```
* 2 Put your source file in the *code* directory:
    - see https://github.com/pixelhumain/pixelhumain/blob/master/README.md
    - use the docker image provided below
    - Your VCS / IDE / ...
* 3 Start the containers using:
```
docker-compose -f docker-compose.yml up
```
* 4 Access to the test service through http://127.0.0.1:5080/ph/index.php/test
* 5 Access to communecter through http://127.0.0.1:5090/ph/
* 6 You can modify your sources code with your prefered editor in the code directory

# Layout overview

```
|-- code
    |-- modules
        |-- communecter
        |-- citizenToolKit
        |-- cityData
        |-- opendata
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
