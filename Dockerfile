FROM eclipse-temurin:17

MAINTAINER BiGCaT

#ENV PORT 8080

RUN apt-get update
RUN apt-get install jq -y

COPY setup.sh /
RUN chmod +x setup.sh
RUN /setup.sh

#The following 2 lines are normally commented out. For local, small scale testing, they can be used (see setup.sh for explanations). This would require the COPY of the .bridge file, and commenting out all lines related to the automated creation of gbd.config in the setup.sh script.
#COPY Hs_Derby_Ensembl_108.bridge /opt/bridgedb-databases/
#COPY gdb.config /opt/bridgedb/bridgedb/

COPY startup.sh /opt/bridgedb/bridgedb/
RUN chmod +x /opt/bridgedb/bridgedb/startup.sh

EXPOSE 8183 
#8080

ENTRYPOINT /opt/bridgedb/bridgedb/startup.sh -f /opt/bridgedb-databases/gdb.config
CMD ["-D", "FOREGROUND"]
