#git clone https://github.com/bridgedb/swagger-webservice.git
git clone --single-branch --branch 2.x https://github.com/swagger-api/swagger-ui.git

docker build --no-cache -t "d" .
#docker build -t p .
sudo docker tag d bigcatum/bridgedb:all-v1

#sudo docker tag -f p dtlfair/search
sudo docker push bigcatum/bridgedb:all-v1

