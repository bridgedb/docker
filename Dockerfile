FROM openjdk:11-jdk

MAINTAINER BiGCaT

ENV PORT 8080

RUN apt-get update
RUN apt-get install apache2 -y
RUN apt-get install jq -y

COPY setup.sh /
RUN chmod +x setup.sh
RUN /setup.sh

#COPY gdb.config /opt/bridgedb/bridgedb-3.0.14/
COPY startup.sh /opt/bridgedb/bridgedb-3.0.14/

RUN chmod +x /opt/bridgedb/bridgedb-3.0.14/startup.sh


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
COPY swagger-ui/dist/ /var/www/html/swagger/
COPY index.html /var/www/html/swagger/
COPY bridgedb.png /var/www/html/swagger/
COPY swagger.json /var/www/html/swagger/


EXPOSE 8183 8080

ENTRYPOINT service apache2 start && /opt/bridgedb/bridgedb-3.0.14/startup.sh -f /opt/bridgedb-databases/gdb.config
CMD ["-D", "FOREGROUND"]
