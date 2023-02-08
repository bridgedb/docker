#!/bin/sh

# change to directory of this script
cd $(dirname $0)

#find . org.bridgedb.server.jar
#java -jar -DserverURL="/swagger/" dist/bridgedbServer.jar

# change to directory of this script

pwd
ls -al dist
java -jar dist/bridgedb-webservice-2.0.1.jar
java -cp "dist/*" org.bridgedb.server.Server "$@" > bridgedb.log
