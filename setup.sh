#!/bin/bash
#apt-get update
##
#apt-get -y install wget
#apt-get -y install zip unzip
#whoami

#IMPORTANT
#This line is updated at every run of https://github.com/bridgedb/docker/blob/master/.github/workflows/buildandpush.yml substituting the
#bridgedbwsversion with the one declared in the bridgedbwservice pom (https://raw.githubusercontent.com/bridgedb/BridgeDbWebservice/main/pom.xml).
#The changes are NOT committed and pushed, but are effective when running setup.sh in the action.
export BRIDGEDBWSVERSION="2.1.6"

cd /opt/
mkdir -p bridgedb/bridgedb/

wget -O /opt/bridgedb/bridgedb/BridgeDb-Webservice.jar https://github.com/bridgedb/BridgeDbWebservice/releases/download/${BRIDGEDBWSVERSION}/BridgeDbWebservice-${BRIDGEDBWSVERSION}-jar-with-dependencies.jar

cd /
mkdir /opt/bridgedb-databases/
cd /opt/bridgedb-databases/

#BRIDGEDB DATABASES
#Option 1A: Get bridgedb databases MANUALLY + new download. 
#If .bridge files are not yet downloaded: For each one, also add line in gdb.config. The Dockerfile should also include the line that copies the gdb.config file.
#wget https://zenodo.org/record/7781913/files/Hs_Derby_Ensembl_108.bridge
#COPY gdb.config /opt/bridgedb/bridgedb/

#Option 1B: Get bridgedb databases MANUALLY without new download.
#If .bridge file already downloaded and stored in the same folder as the Dockerfile, add the following line into the Dockerfile right after the line to run the setup.sh file, for each bridgedb database. This should be followed by the line that copies the gdb.config file.
#COPY Hs_Derby_Ensembl_108.bridge /opt/bridgedb-databases/
#COPY gdb.config /opt/bridgedb/bridgedb/

#Option 2: Get all bridgedb databases AUTOMATICALLY. 
#Comment out all lines below if testing locally on small scale, with a direct COPY of the .bridge file

wget -nc https://bridgedb.github.io/data/gene.json
wget -nc https://bridgedb.github.io/data/corona.json
wget -nc https://bridgedb.github.io/data/other.json

wget -nc https://bridgedb.github.io/data/gene.json.config
wget -nc https://bridgedb.github.io/data/corona.json.config
wget -nc https://bridgedb.github.io/data/other.json.config

cat gene.json.config >> gdb.config
cat corona.json.config >> gdb.config
cat other.json.config >> gdb.config

grep -v "Ec_Derby_Ensembl_91.bridge" gdb.config > tmpfile && mv tmpfile gdb.config
grep -v "Mx_Derby_Ensembl_85.bridge" gdb.config > tmpfile && mv tmpfile gdb.config

jq -r '.mappingFiles | .[] | select(.tested) | select(.tested|.[]|test(.|"WS")) | "\(.file)=\(.downloadURL)"' gene.json >> files.txt
jq -r '.mappingFiles | .[] | select(.tested) | select(.tested|.[]|test(.|"WS")) | "\(.file)=\(.downloadURL)"' corona.json >> files.txt
jq -r '.mappingFiles | .[] | select(.tested) | select(.tested|.[]|test(.|"WS")) | "\(.file)=\(.downloadURL)"' other.json >> files.txt

grep -v "Ec_Derby_Ensembl_91.bridge" files.txt > tmpfile && mv tmpfile files.txt
grep -v "Mx_Derby_Ensembl_85.bridge" files.txt > tmpfile && mv tmpfile files.txt


for FILE in $(cat files.txt)
do
  readarray -d = -t splitFILE<<< "$FILE"
  echo ${splitFILE[0]}
  wget -nc -O ${splitFILE[0]} ${splitFILE[1]}
done

#Remove files that do not work
rm Ec_Derby_Ensembl_91.bridge
rm Mx_Derby_Ensembl_85.bridge

sed -i -e 's/\t/\t\/opt\/bridgedb-databases\//g' gdb.config
cp gdb.config /opt/bridgedb/bridgedb/



