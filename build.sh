#!/bin/sh

###  env variables
export SIGNOMIX_GA_TRACKING_ID=NONE
export SIGNOMIX_STATUSPAGE_URL=/

### signomix
cd ../signomix
mvn package

### signomix-ta-ps
cd ../signomix-ta-ps
cd src/main/webapp/home
npm install
npm run build
cd ../blog
npm install
npm run build
cd ../../../..
sh update-webapps.sh
./mvnw package

### signomix-ta-app
cd ../signomix-ta-app
sh update-webapps.sh
./mvnw package

### signomix-ta-ms
cd ../signomix-ta-ms
./mvnw package

cd ../signomix-ta
docker-compose build