#! /bin/sh
# Update mosquitto.conf file in the mosquitto container volume
cp ./mosquitto/cfg/mosquitto.conf ~/signomix/volumes/mosquitto/config
# run docker compose with the dev.env file
docker compose --env-file ./dev.env $1 $2 $3
