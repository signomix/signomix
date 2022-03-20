#!/bin/sh

cd ..
git clone https://github.com/signomix/signomix-proxy.git
git clone https://github.com/signomix/signomix-rabbitmq.git
git clone https://github.com/signomix/signomix.git
git clone https://github.com/signomix/signomix-ta-ps.git
git clone https://github.com/signomix/signomix-ta-app.git
git clone https://github.com/signomix/signomix-ta-ms.git
git clone https://github.com/signomix/signomix-database.git

mkdir -p volumes/volume-db
mkdir -p volumes/volume-ps/logs
mkdir -p volumes/volume-service/db
mkdir -p volumes/volume-service/logs
mkdir -p volumes/volume-service/files
mkdir -p volumes/volume-service/backup
mkdir -p volumes/volume-proxy