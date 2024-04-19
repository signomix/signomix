#!/bin/sh

# Script to create required folders for Docker volumes

# Create required folders for Docker volumes
mkdir -p ~/signomix/volumes/mosquitto/config
mkdir -p ~/signomix/volumes/mosquitto/data
mkdir -p ~/signomix/volumes/mosquitto/log
mkdir -p ~/signomix/volumes/volume-postgres
mkdir -p ~/signomix/volumes/volume-questdb
git clone https://github.com/signomix/signomix-documentation.git ~/signomix/volumes/signomix-documentation