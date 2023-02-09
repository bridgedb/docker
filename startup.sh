#!/bin/sh

# change to directory of this script
cd $(dirname $0)

#find . org.bridgedb.server.jar
#java -jar -DserverURL="/swagger/" dist/bridgedbServer.jar

# change to directory of this script

pwd
apt install nmap -y
nmap localhost
ls -al dist
sed -i 's/SERVER_URL/$SERVER_URL' /var/www/html/swagger/swagger.json
java -jar dist/bridgedb-webservice-2.0.2.jar 8183 > bridgedb.log
