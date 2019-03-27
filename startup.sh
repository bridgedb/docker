#!/bin/sh

# change to directory of this script
cd $(dirname $0)

java -jar -DserverURL="/swagger/" dist/org.bridgedb.server.jar
