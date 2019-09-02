git clone https://github.com/swagger-api/swagger-ui.git
git checkout -b bridgedb ccf17e90e2

docker build --no-cache -t "d" .
#docker build -t p .
sudo docker tag d bigcatum/bridgedb:2.3.3-test

#sudo docker tag -f p dtlfair/search
sudo docker push bigcatum/bridgedb:2.3.3-test
