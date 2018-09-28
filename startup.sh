#!/bin/sh

# change to directory of this script
cd $(dirname $0)

java -jar -DserverURL="http://127.0.0.1:8080/swagger/" dist/org.bridgedb.server.jar
