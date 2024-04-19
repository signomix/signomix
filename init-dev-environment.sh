#!/bin/sh

# Script to clone Signomix repositories and create required folders for Docker volumes


# assuming that you have cloned the signomix-ta repository to the `~/workspace/signomix-ta` folder
# and you want to clone all other repositories to `~/workspace` subfolders.
cd ..

# Clone Signomix repositories
git clone https://github.com/signomix/signomix-ta-account.git
git clone https://github.com/signomix/signomix-apigateway.git
git clone https://github.com/signomix/signomix-ta-app.git
git clone https://github.com/signomix/signomix-auth.git
git clone https://github.com/signomix/signomix-common.git
git clone https://github.com/signomix/signomix-docs-website.git
git clone https://github.com/signomix/signomix-ta-core.git
git clone https://github.com/signomix/signomix-ta-jobs.git
git clone https://github.com/signomix/signomix-ta-ms.git
git clone https://github.com/signomix/signomix-ta-provider.git
git clone https://github.com/signomix/signomix-ta-receiver.git
git clone https://github.com/signomix/signomix-reports.git
git clone https://github.com/signomix/signomix-sentinel.git
git clone https://github.com/signomix/signomix-webapp.git
git clone https://github.com/signomix/signomix-view.git

# Create required folders for Docker volumes
mkdir -p ~/signomix/volumes/mosquitto/config
mkdir -p ~/signomix/volumes/mosquitto/data
mkdir -p ~/signomix/volumes/mosquitto/log
mkdir -p ~/signomix/volumes/volume-postgres
mkdir -p ~/signomix/volumes/volume-questdb
git clone https://github.com/signomix/signomix-documentation.git ~/signomix/volumes/signomix-documentation