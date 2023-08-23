FROM openjdk:11-jdk

MAINTAINER BiGCaT

ENV PORT 8080

RUN apt-get update
RUN apt-get install apache2 -y
RUN apt-get install jq -y

COPY setup.sh /
RUN chmod +x setup.sh
RUN /setup.sh

#The line is normally commented out. For local, small scale testing, it can be used. This would require the COPY of the .bridge file, and commenting out all lines related to the creation of gbd.config in the setup.sh script.
COPY gdb.config /opt/bridgedb/bridgedb/

COPY startup.sh /opt/bridgedb/bridgedb/
RUN chmod +x /opt/bridgedb/bridgedb/startup.sh

#Comment out the 3 line below if gdb.config is created automatically.
RUN wget https://zenodo.org/record/7781913/files/Hs_Derby_Ensembl_108.bridge
RUN mv Hs_Derby_Ensembl_108.bridge /opt/bridgedb-databases/
#If derby file is outside container, use the following line
#COPY Hs_Derby_Ensembl_108.bridge /opt/bridgedb-databases/

COPY ports.conf /etc/apache2
COPY 000-default.conf /etc/apache2/sites-enabled/

RUN a2enmod proxy \
&& a2enmod proxy_http \
&& a2enmod ssl \
&& a2enmod rewrite \
&& service apache2 stop

COPY ports.conf /etc/apache2
COPY 000-default.conf /etc/apache2/sites-enabled/

#improve with configuration change instead of copy
#CMD sed -i "s/80/$PORT/g" /etc/apache2/sites-available/000-default.conf
#CMD sed -i "s/80/$PORT/g" /etc/apache2/ports.conf 

RUN mkdir /var/www/html/swagger/
COPY v3/ /var/www/html/swagger/
COPY index.html /var/www/html/swagger/
COPY bridgedb.png /var/www/html/swagger/

EXPOSE 8183 8080

ENTRYPOINT service apache2 start && /opt/bridgedb/bridgedb/startup.sh -f /opt/bridgedb-databases/gdb.config
CMD ["-D", "FOREGROUND"]
