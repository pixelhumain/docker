* 1 Create a folder named *code* that will work as a work directory.
* 2 Put your source file in the *code* directory (follow « Adding a module » from https://github.com/pixelhumain/pixelhumain/blob/master/README.md
  Example using git for an initial setup:
```
mkdir -p code/modules
git clone https://github.com/pixelhumain/pixelhumain.git code/pixelhumain
git clone https://github.com/pixelhumain/communecter.git code/modules/communecter
git clone https://github.com/pixelhumain/citizenToolkit code/modules/citizenToolKit
```
* 3 Start the containers using:
```
docker-compose -f docker-compose.yml  up --build
```
* 4 Access to the test service through http://127.0.0.1:5000/ph/index.php/test (port configurable in the docker-compose.yml)
* 4 Access to communecter through http://127.0.0.1:5000/ph/ (port configurable in the docker-compose.yml)
* 5 (opt) For an initial setup you'll need to init MongoDB, configurations, etc (see communecter install guide for more detail), an easy to use script is provided through install.sh
```
$ # Enter your container through `docker exec` (you can use `docker ps` to see which containers are running
$ docker ps
CONTAINER ID        IMAGE                     [...] NAMES
279479507ecb        pixelhumaindocker_front   [...] pixelhumaindocker_front_1
e5532c34570e        mongo                     [...] pixelhumaindocker_mongo_1
...
$ docker exec -ti pixelhumaindocker_front_1 /bin/bash
# # Then execute the install script
# /tmp/install.sh
```
* 6 You can modify your sources code with your prefered editor
