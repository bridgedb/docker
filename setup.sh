#!/bin/bash
#apt-get update
##
#apt-get -y install wget
#apt-get -y install zip unzip
#whoami
export BRIDGEDBWSVERSION="2.1.4"

cd /opt/
mkdir -p bridgedb/bridgedb/

wget -O /opt/bridgedb/bridgedb/BridgeDb-Webservice.jar https://github.com/bridgedb/BridgeDbWebservice/releases/download/${BRIDGEDBWSVERSION}/BridgeDbWebservice-${BRIDGEDBWSVERSION}-jar-with-dependencies.jar

cd /
mkdir /opt/bridgedb-databases/
cd /opt/bridgedb-databases/


#get bridgedb databases
wget -nc https://bridgedb.github.io/data/gene.json
wget -nc https://bridgedb.github.io/data/corona.json
wget -nc https://bridgedb.github.io/data/other.json

wget -nc https://bridgedb.github.io/data/gene.json.config
wget -nc https://bridgedb.github.io/data/corona.json.config
wget -nc https://bridgedb.github.io/data/other.json.config

cat gene.json.config >> gdb.config
cat corona.json.config >> gdb.config
cat other.json.config >> gdb.config

jq -r '.mappingFiles | .[] | "\(.file)=\(.downloadURL)"' gene.json >> files.txt
jq -r '.mappingFiles | .[] | "\(.file)=\(.downloadURL)"' corona.json >> files.txt
jq -r '.mappingFiles | .[] | "\(.file)=\(.downloadURL)"' other.json >> files.txt

for FILE in $(cat files.txt)
do
  readarray -d = -t splitFILE<<< "$FILE"
  echo ${splitFILE[0]}
  wget -nc -O ${splitFILE[0]} ${splitFILE[1]}
done

sed -i -e 's/\t/\t\/opt\/bridgedb-databases\//g' gdb.config
cp gdb.config /opt/bridgedb/bridgedb/



