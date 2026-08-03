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
export BRIDGEDBWSVERSION="2.1.9"

cd /opt/
mkdir -p bridgedb/bridgedb/

wget -O /opt/bridgedb/bridgedb/BridgeDb-Webservice.jar https://github.com/bridgedb/BridgeDbWebservice/releases/download/${BRIDGEDBWSVERSION}/BridgeDbWebservice-${BRIDGEDBWSVERSION}-jar-with-dependencies.jar

# Fail the build if the webservice JAR did not download as a valid archive.
# A JAR is a ZIP, so a good one is non-empty and starts with the "PK" signature.
if [ ! -s /opt/bridgedb/bridgedb/BridgeDb-Webservice.jar ] || [ "$(head -c 2 /opt/bridgedb/bridgedb/BridgeDb-Webservice.jar)" != "PK" ]; then
  echo "ERROR: BridgeDb-Webservice.jar failed to download (missing, empty, or not a JAR)." >&2
  exit 1
fi

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

# Use figshare's legacy ndownloader host. The figshare.com/ndownloader/... host
# sits behind an AWS WAF JavaScript challenge (responds HTTP 202 with header
# x-amzn-waf-action: challenge) that non-browser clients -- wget, and the GitHub
# Actions runner -- cannot solve, so downloads come back empty. The host
# ndownloader.figshare.com serves the same file IDs directly without the challenge.
sed -i 's#https://figshare.com/ndownloader/files/#https://ndownloader.figshare.com/files/#g' files.txt


# Download each mapping database, retrying on transient failures. Some sources
# (e.g. figshare) reply HTTP 202 with an empty body while a file is still being
# staged, which wget would otherwise save as a 0-byte file. .bridge files are ZIP
# archives, so a valid one is non-empty and starts with the "PK" signature.
# Abort the build if a file cannot be fetched as a valid archive -- this prevents
# publishing an image with a corrupt database that crashes the webservice on start.
for FILE in $(cat files.txt)
do
  # Split "name=url" with parameter expansion. (readarray + <<< would append a
  # stray newline to the URL, which wget then sends URL-encoded as %0A.)
  NAME=${FILE%%=*}
  URL=${FILE#*=}
  echo "Downloading ${NAME}"
  attempt=1
  until [ -s "${NAME}" ] && [ "$(head -c 2 "${NAME}")" = "PK" ]
  do
    if [ ${attempt} -gt 10 ]; then
      echo "ERROR: ${NAME} could not be downloaded as a valid .bridge archive after 10 attempts (${URL})." >&2
      exit 1
    fi
    [ ${attempt} -gt 1 ] && { echo "  attempt ${attempt} failed (empty or not a ZIP); retrying in 30s..."; sleep 30; }
    wget -nv -O "${NAME}" "${URL}"
    attempt=$((attempt + 1))
  done
done

#Remove files that do not work
rm Ec_Derby_Ensembl_91.bridge
rm Mx_Derby_Ensembl_85.bridge

sed -i -e 's/\t/\t\/opt\/bridgedb-databases\//g' gdb.config
cp gdb.config /opt/bridgedb/bridgedb/
