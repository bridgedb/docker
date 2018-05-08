# Welcome to the BridgeDb Docker repository!

BridgeDb is a framework for finding and mapping equivalent database identifiers. For local use, we work on a docker image. This docker image is located on DockerHub: https://hub.docker.com/r/bigcatum/bridgedb/

For Windows users, it is required to download Docker (https://www.docker.com/get-docker) and Docker toolbox (https://docs.docker.com/toolbox/overview/). Afterwards, start the docker quickstart terminal and let is set up a VirtualBox environment.

## Pulling the image from DockerHub

To pull the image from dockerhub, enter the following line:

    docker pull bigcatum/bridgedb

At the moment, this docker image is being developed and refined, and has the 'development' tag. To pull this docker image and test it, use the following command:

    docker pull bigcatum/bridgedb:develop-human-2

This step might take some time, depending on the amount of mapping datasets (.bridge-files) are being downloaded during this step. Currently, the main docker image consists of all .bridge files for identifier mapping of all species that are covered in BridgeDb.

To confirm that this step has worked and the docker image is pulled correctly, enter the following:

    docker images

This will give an overview of all images that are downloaded and ready for use.

## Running the docker image in a container

For windows users, it is necessary to know the IP adress of the VirtualBox environment, which you can find by using the following command:

    docker-machine ip

To run the docker image that you just downloaded, the following line should be entered:

    docker run -p 8080:8080 -p 8183:8183 bigcatum/bridgedb:develop-human-2

## Opening the docker image in a browser

To enter the docker image in a browser, Windows users should enter the IP-adress of the VirtualBox, vollowed by ':8080/swagger/'. On Unix, the docker image can be entered by writing 'http://localhost:8080/swagger/' in their browser.

## Stopping the running container

To stop a container with the running image, one needs to know the container ID, which can be found with the following command:

    docker ps -a
    
This command shows all containers on your VirtualBox Environment, including their IDs. To stop a container, enter:

    docker stop [container ID]

