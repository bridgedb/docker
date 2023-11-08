#!/bin/sh

# change to directory of this script
cd $(dirname $0)

#find . org.bridgedb.server.jar
#java -jar -DserverURL="/swagger/" dist/bridgedbServer.jar

# change to directory of this script

pwd
java -jar BridgeDb-Webservice.jar 8183 true $SERVER_URL > bridgedb.log
