#!/bin/bash

#apt-get update

#apt-get -y install wget
#apt-get -y install zip unzip
whoami

cd /opt/
mkdir bridgedb/
cd bridgedb/

wget http://bridgedb.org/data/releases/bridgedb-2.2.1.tar.gz
tar -xvzf bridgedb-2.2.1.tar.gz bridgedb-2.2.1

mkdir /opt/bridgedb-databases/
cd /opt/bridgedb-databases/

#wget -r -l1 --no-parent -A ".bridge" http://bridgedb.org/data/gene_database/
#wget -r -l1 --no-parent -A "Hs_Derby_Ensembl_89.bridge" http://bridgedb.org/data/gene_database/
wget -r -l1 --no-parent -A "Xt_Derby_Ensembl_89.bridge" http://bridgedb.org/data/gene_database/
wget -r -l1 --no-parent -A "Zm_Derby_Ensembl_Plant_37.bridge" http://bridgedb.org/data/gene_database/
#wget -r -l1 --no-parent http://bridgedb.org/data/gene_database/Ag_Derby_Ensembl_Metazoa_32.bridge.zip
#wget -r -l1 --no-parent -A ".zip" http://bridgedb.org/data/gene_database/
#cd /opt/bridgedb-databases/bridgedb.org/data/gene_database/
#unzip *.zip

#cd bridgedb-2.2.1

