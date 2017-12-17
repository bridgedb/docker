FROM openjdk:8-jdk

MAINTAINER BiGCaT


COPY setup.sh /
RUN chmod +x setup.sh
RUN /setup.sh

COPY gdb.config /opt/bridgedb/bridgedb-2.2.1/

RUN chmod +x /opt/bridgedb/bridgedb-2.2.1/start-server.sh
ENTRYPOINT /opt/bridgedb/bridgedb-2.2.1/start-server.sh
