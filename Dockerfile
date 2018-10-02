FROM openjdk:8-jdk

MAINTAINER BiGCaT

ENV PORT 8080

COPY setup.sh /
RUN chmod +x setup.sh
RUN /setup.sh

COPY gdb.config /opt/bridgedb/bridgedb-2.3.0/
COPY startup.sh /opt/bridgedb/bridgedb-2.3.0/

RUN chmod +x /opt/bridgedb/bridgedb-2.3.0/startup.sh

RUN apt-get update
RUN apt-get install apache2 -y

RUN a2enmod proxy \
&& a2enmod proxy_http \
&& a2enmod ssl \
&& a2enmod rewrite \
&& service apache2 stop

#improve with configuration change instead of copy
#CMD sed -i "s/80/$PORT/g" /etc/apache2/sites-available/000-default.conf
#CMD sed -i "s/80/$PORT/g" /etc/apache2/ports.conf 

COPY ports.conf /etc/apache2
COPY 000-default.conf /etc/apache2/sites-enabled/

RUN mkdir /var/www/html/swagger/
COPY resources/swagger-ui/dist/ /var/www/html/swagger/
COPY resources/swagger-webservice/ /var/www/html/swagger/

EXPOSE 8183 8080

ENTRYPOINT service apache2 start && /opt/bridgedb/bridgedb-2.3.0/startup.sh
