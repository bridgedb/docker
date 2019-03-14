#!/bin/bash

#apt-get update

#apt-get -y install wget
#apt-get -y install zip unzip
#whoami

cd /opt/
mkdir bridgedb/
cd bridgedb/

wget https://www.bridgedb.org/data/releases/bridgedb-2.3.0.tar.gz
tar -xvzf bridgedb-2.3.0.tar.gz bridgedb-2.3.0

mkdir /opt/bridgedb-databases/
cd /opt/bridgedb-databases/


export ENSEMBLMAIN="91"

wget -r -l1 --no-parent -A "*91.bridge" https://www.bridgedb.org/data/gene_database/
wget -r -l1 --no-parent -A "*39.bridge" https://www.bridgedb.org/data/gene_database/

#wget -r -l1 --no-parent -A "Hs_Derby_Ensembl_${ENSEMBLMAIN}.bridge" https://www.bridgedb.org/data/gene_database/
#wget -r -l1 --no-parent -A "Mm_Derby_Ensembl_${ENSEMBLMAIN}.bridge" https://www.bridgedb.org/data/gene_database/
#wget -r -l1 --no-parent -A "Rn_Derby_Ensembl_${ENSEMBLMAIN}.bridge" https://www.bridgedb.org/data/gene_database/


#wget -r -l1 --no-parent https://bridgedb.org/data/gene_database/Ag_Derby_Ensembl_Metazoa_32.bridge.zip
#wget -r -l1 --no-parent -A ".zip" https://bridgedb.org/data/gene_database/
#cd /opt/bridgedb-databases/bridgedb.org/data/gene_database/
#unzip *.zip

cd /opt/bridgedb-databases/www.bridgedb.org/data/gene_database
wget -c -O metabolites-20181224.bridge "https://ndownloader.figshare.com/files/13902533"

#cd bridgedb-2.2.1

