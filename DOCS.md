- Create a folder named *code* that will work as a work directory.
- Put your source file in the *code* directory
- Start the containers using:
    docker-compose -f docker-compose.yml  up --build
- Access to the services through http://127.0.0.1:5000 (port configurable in the docker-compose.yml)
