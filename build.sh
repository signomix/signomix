#!/bin/sh

###  env variables
export SIGNOMIX_GA_TRACKING_ID=NONE
export SIGNOMIX_STATUSPAGE_URL=/

### signomix
cd ../signomix
mvn clean package

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
./mvnw clean package

### signomix-ta-app
cd ../signomix-ta-app
sh update-webapps.sh
./mvnw clean package

### signomix-ta-ms
cd ../signomix-ta-ms
./mvnw clean package

### signomix-ta-receiver
cd ../signomix-ta-receiver
./mvnw clean package

### signomix-ta-account
cd ../signomix-ta-account
./mvnw clean package

cd ../signomix-ta
docker-compose build