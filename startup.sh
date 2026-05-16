#!/bin/sh

# change to directory of this script
cd $(dirname $0)

#find . org.bridgedb.server.jar
#java -jar -DserverURL="/swagger/" dist/bridgedbServer.jar

# change to directory of this script

pwd
# -Djdbc.drivers force-registers the Derby JDBC driver. The 2.1.8 webservice
# fat JAR has a clobbered META-INF/services/java.sql.Driver (only lists MySQL),
# so Derby would otherwise not auto-register and no .bridge file can be opened.
java -Djdbc.drivers=org.apache.derby.jdbc.EmbeddedDriver -jar BridgeDb-Webservice.jar 8183 true $SERVER_URL > bridgedb.log
