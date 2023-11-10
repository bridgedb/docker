[![docker stars](https://img.shields.io/docker/stars/bigcatum/bridgedb.svg?style=flat-square)](https://hub.docker.com/r/bigcatum/bridgedb)
[![docker pulls](https://img.shields.io/docker/pulls/bigcatum/bridgedb.svg?style=flat-square)](https://hub.docker.com/r/bigcatum/bridgedb)
[![Docker build](https://github.com/bridgedb/docker/actions/workflows/buildandpush.yml/badge.svg)](https://github.com/bridgedb/docker/actions/workflows/buildandpush.yml)

# Welcome to the BridgeDb Docker repository!

BridgeDb is a framework for finding and mapping equivalent database identifiers. This repository involves the Docker image of the BridgeDb service. This docker image is located on DockerHub: https://hub.docker.com/r/bigcatum/bridgedb/

For Windows users, it is required to download Docker (https://www.docker.com/get-docker) and Docker toolbox (https://docs.docker.com/toolbox/overview/). Afterwards, start the docker quickstart terminal and let is set up a VirtualBox environment.

## Pulling the image from DockerHub

To pull the image from DockerHub, enter the following line:

```
docker pull bigcatum/bridgedb:latest
```

To pull a BridgeDb Docker Image with a specific version, use the following command and fill in the tag:
```
docker pull bigcatum/bridgedb:[tag]
```
Currently, the main docker image consists of all available identifier mapping (.bridge) files. The tags of the Docker images describe the BridgeDb version and the version of the web service. For example, the Docker image of bigcatum/bridgedb:3.0.23-2.1.6 has the BridgeDb version os 3.0.23 and the webservice version of 2.1.6.

To confirm that this step has worked and the Docker Image was pulled correctly, enter the following:
```
docker images
```
This will give an overview of all images that are downloaded and ready for use.

## Running the docker image in a container

For windows users, it is necessary to know the IP adress of the VirtualBox environment, which you can find by using the following command:

```
docker-machine ip
```
Below is the command for running the Docker Image. In the command, change `[PORT1]` to configure ports that are not yet in use in your system. If the ports 8183 is not yet in use, you can simply use that one for `[PORT1]`. The environment variable `[SERVER_URL]` defines the host URL, depending on where the Docker Image will be run. If you do a local deployment, the `[SERVER_URL]` should be http://localhost, with the `[PORT1]` that you chose. The `[TAG]` corresponds to the version of the Docker image that you pulled.

```
sudo docker run --name bridgedb --rm -p [PORT1]:8183 -e SERVER_URL='[SERVER_URL]:[PORT1]' bigcatum/bridgedb:[TAG]
```
## Opening the docker image in a browser

To enter the docker image in a browser, Windows users should enter the IP-adress of the VirtualBox, followed by ':[PORT1]'. On Linux, the docker image can be entered by writing 'http://localhost:[PORT1]' in the browser.

## Stopping the running container

To see the status of the service, use the following command:
```
docker ps -a
```   
To stop a container, enter the following line. This will automatically remove the container (because of the `--rm` flag in the `docker run` command above):
```
docker stop bridgedb
```

