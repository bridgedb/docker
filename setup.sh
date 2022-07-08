#!/bin/bash

#apt-get update

#apt-get -y install wget
#apt-get -y install zip unzip
#whoami
export BRIDGEDBVERSION="3.0.14"

cd /opt/
mkdir bridgedb/
cd bridgedb/

#wget https://github.com/bridgedb/BridgeDb/archive/refs/tags/release_3.0.5.zip
#unzip release_3.0.5.zip

mkdir -p bridgedb-${BRIDGEDBVERSION}/dist

cd bridgedb-${BRIDGEDBVERSION}/dist



#download single JAR (replaces JARs and dependencies)
#wget -O org.bridgedb.server-${BRIDGEDBVERSION}.jar https://github.com/bridgedb/bridgedb-webservice/releases/download/release_3.0.14/bridgedbServer.jar

#download JARs
wget -O org.bridgedb.server-${BRIDGEDBVERSION}.jar https://search.maven.org/remotecontent?filepath=org/bridgedb/org.bridgedb.server/${BRIDGEDBVERSION}/org.bridgedb.server-${BRIDGEDBVERSION}.jar
wget -O org.bridgedb.bio-${BRIDGEDBVERSION}.jar https://search.maven.org/remotecontent?filepath=org/bridgedb/org.bridgedb.bio/${BRIDGEDBVERSION}/org.bridgedb.bio-${BRIDGEDBVERSION}.jar
wget -O org.bridgedb.rdb-${BRIDGEDBVERSION}.jar https://search.maven.org/remotecontent?filepath=org/bridgedb/org.bridgedb.rdb/${BRIDGEDBVERSION}/org.bridgedb.rdb-${BRIDGEDBVERSION}.jar
wget -O org.bridgedb.webservice.bridgerest-${BRIDGEDBVERSION}.jar https://search.maven.org/remotecontent?filepath=org/bridgedb/webservice/org.bridgedb.webservice.bridgerest/${BRIDGEDBVERSION}/org.bridgedb.webservice.bridgerest-${BRIDGEDBVERSION}.jar
wget -O org.bridgedb-${BRIDGEDBVERSION}.jar https://search.maven.org/remotecontent?filepath=org/bridgedb/org.bridgedb/${BRIDGEDBVERSION}/org.bridgedb-${BRIDGEDBVERSION}.jar
wget -O derbyclient-10.14.2.0.jar https://search.maven.org/remotecontent?filepath=org/apache/derby/derbyclient/10.14.2.0/derbyclient-10.14.2.0.jar
wget -O derby-10.14.2.0.jar https://search.maven.org/remotecontent?filepath=org/apache/derby/derby/10.14.2.0/derby-10.14.2.0.jar

#dependencies
wget -O commons-cli-1.2.jar https://search.maven.org/remotecontent?filepath=commons-cli/commons-cli/1.2/commons-cli-1.2.jar
wget -O org.restlet.ext.servlet-2.0.15.jar http://maven.restlet.org/org/restlet/jee/org.restlet.ext.servlet/2.0.15/org.restlet.ext.servlet-2.0.15.jar
wget -O org.restlet-2.0.15.jar http://maven.restlet.org/org/restlet/jee/org.restlet/2.0.15/org.restlet-2.0.15.jar

cd ../../
mkdir /opt/bridgedb-databases/
cd /opt/bridgedb-databases/


#get bridgedb databases
wget -nc https://bridgedb.github.io/data/gene.json
wget -nc https://bridgedb.github.io/data/corona.json
wget -nc https://bridgedb.github.io/data/other.json

wget -nc https://bridgedb.github.io/data/gene.json.config
wget -nc https://bridgedb.github.io/data/corona.json.config
wget -nc https://bridgedb.github.io/data/other.json.config

cat gene.json.config > gdb.config
cat corona.json.config >> gdb.config
cat other.json.config >> gdb.config

jq -r '.mappingFiles | .[] | "\(.file)=\(.downloadURL)"' gene.json > files.txt
jq -r '.mappingFiles | .[] | "\(.file)=\(.downloadURL)"' corona.json >> files.txt
jq -r '.mappingFiles | .[] | "\(.file)=\(.downloadURL)"' other.json >> files.txt

for FILE in $(cat files.txt)
do
  readarray -d = -t splitFILE<<< "$FILE"
  echo ${splitFILE[0]}
  wget -nc -O ${splitFILE[0]} ${splitFILE[1]}
done

sed -i -e 's/\t/\t\/opt\/bridgedb-databases\//g' gdb.config


#export ENSEMBLMAIN="91"

#wget -O Ec_Derby_Ensembl_91.bridge "https://zenodo.org/record/3667670/files/Ec_Derby_Ensembl_91.bridge"
#wget -r "https://zenodo.org/record/3667670/files/Rn_Derby_Ensembl_91.bridge" https://www.bridgedb.org/data/gene_database/
#wget -r "https://zenodo.org/record/3667670/files/Mm_Derby_Ensembl_91.bridge" https://www.bridgedb.org/data/gene_database/
#wget -r -l1 --no-parent -A "*39.bridge"

#wget -r -l1 --no-parent -A "Hs_Derby_Ensembl_${ENSEMBLMAIN}.bridge" https://www.bridgedb.org/data/gene_database/
#wget -r -l1 --no-parent -A "Mm_Derby_Ensembl_${ENSEMBLMAIN}.bridge" https://www.bridgedb.org/data/gene_database/
#wget -r -l1 --no-parent -A "Rn_Derby_Ensembl_${ENSEMBLMAIN}.bridge" https://www.bridgedb.org/data/gene_database/


#wget -r -l1 --no-parent https://bridgedb.org/data/gene_database/Ag_Derby_Ensembl_Metazoa_32.bridge.zip
#wget -r -l1 --no-parent -A ".zip" https://bridgedb.org/data/gene_database/
#cd /opt/bridgedb-databases/bridgedb.org/data/gene_database/
#unzip *.zip

#cd /opt/bridgedb-databases/www.bridgedb.org/data/gene_database
#wget -c -O metabolites-20200809.bridge "https://ndownloader.figshare.com/files/24180464"

