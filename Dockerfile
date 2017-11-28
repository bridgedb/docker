FROM openjdk:8-jdk

MAINTAINER BiGCaT

RUN apt-get update

#RUN sysctl -w vm.max_map_count=262144
#RUN echo "vm.max_map_count=262144" >> /etc/sysctl.conf

RUN apt-get update

RUN apt-get -y install wget
RUN apt-get -y install zip unzip

RUN mkdir /opt/bridgedb/
RUN cd /opt/bridgedb/

RUN wget http://bridgedb.org/data/releases/bridgedb-2.2.1.tar.gz
RUN tar -xvzf bridgedb-2.2.1.tar.gz

RUN wget -r -l1 --no-parent -A ".zip" http://bridgedb.org/data/gene_database/
RUN unzip *
RUN cd bridgedb-2.2.1
