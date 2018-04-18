FROM openjdk:8-jdk

MAINTAINER BiGCaT


COPY setup.sh /
RUN chmod +x setup.sh
RUN /setup.sh

COPY gdb.config /opt/bridgedb/bridgedb-2.3.0/

RUN chmod +x /opt/bridgedb/bridgedb-2.3.0/start-server.sh

EXPOSE 8183

ENTRYPOINT /opt/bridgedb/bridgedb-2.3.0/start-server.sh
