#git clone https://github.com/swagger-api/swagger-ui.git
#git checkout -b bridgedb ccf17e90e2

sudo docker build --no-cache -t "d" .
#docker build -t p .
sudo docker tag d bigcatum/bridgedb:3.0.14

#sudo docker tag -f p dtlfair/search
sudo docker push bigcatum/bridgedb:3.0.14
