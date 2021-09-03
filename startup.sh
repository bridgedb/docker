#!/bin/sh

# change to directory of this script
#cd $(dirname $0)

#find . org.bridgedb.server.jar
#java -jar -DserverURL="/swagger/" dist/org.bridgedb.server.jar

# change to directory of this script
cd $(dirname $0)

pwd
ls -al dist
java -cp "dist/*" org.bridgedb.server.Server "$@"
