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

## Testing an image

`tests/` holds the checks that CI runs, and they can be run by hand against any
image or any running service.

To check a complete image — what is baked into it, plus its behaviour once
started:

```
tests/verify-image.sh bigcatum/bridgedb:3.0.31-2.1.9
```

The expected webservice version is taken from the tag; pass it explicitly as a
second argument for an image whose tag does not carry it (such as `:latest`):

```
tests/verify-image.sh bigcatum/bridgedb:latest 2.1.9
```

To test a service that is already running (a container, or a deployed host):

```
tests/smoke-test.sh http://localhost:8183 2.1.9
```

The checks cover the version the service reports for itself, the organism and
datasource catalogues, and real Derby-backed identifier mappings for human and
mouse. Both scripts exit non-zero when a check fails.

Note that the webservice answers **HTTP 200 for unknown paths**, returning an
"Unrecognized query" page rather than a 404, so these checks assert on response
bodies. Any new check should do the same — asserting on the status code alone
would pass against a server that resolves nothing at all.

Two lines in the service log are expected and harmless — they are not signs of a
broken image:

```
Warning: driver 'com.mysql.jdbc.Driver'  not in classpath, some features may not be available.
Unable to parse organism: Fusarium graminearum
```

Also worth knowing when writing checks: 2.1.9 restored **plain TSV** as the
default response format (`BRCA2<TAB>HGNC`), where 2.1.8 returned compact-identifier
JSON (`{"hgnc.symbol:BRCA2":"HGNC"}`). The checks assert on bare identifiers and
datasource names so they hold for both.

In CI, `verify-published-image.yml` runs the same checks weekly against the
image on Docker Hub, and can be started manually for any tag.

