#!/bin/sh

# assuming that your have cloned signomix-ta repository to `~/workspace/signomix-ta` folder
# and you want to clone all other repositories to `~/workspace` subfolders.
cd ..

git clone https://github.com/signomix/signomix-auth.git
git clone https://github.com/signomix/signomix-common.git
git clone https://github.com/signomix/signomix-database.git
git clone https://github.com/signomix/signomix-proxy.git
git clone https://github.com/signomix/signomix-main.git
git clone https://github.com/signomix/signomix-ta-account.git
git clone https://github.com/signomix/signomix-ta-app.git
git clone https://github.com/signomix/signomix-ta-core.git
git clone https://github.com/signomix/signomix-ta-jobs.git
git clone https://github.com/signomix/signomix-ta-ms.git
git clone https://github.com/signomix/signomix-ta-provider.git
git clone https://github.com/signomix/signomix-ta-ps.git
git clone https://github.com/signomix/signomix-ta-receiver.git
git clone https://github.com/signomix/signomix-webapp.git
git clone https://github.com/signomix/docs-website.git
git clone https://github.com/signomix/signomix-view.git
git clone https://github.com/signomix/signomix-sentinel.git
git clone https://github.com/signomix/signomix-documentation.git

# change volumes path from `~/signomix/volumes` to different location if needed
mkdir -p ~/signomix/volumes/assets
mkdir -p ~/signomix/volumes/files
mkdir -p ~/signomix/volumes/volume-db
mkdir -p ~/signomix/volumes/volume-dbbackup
mkdir -p ~/signomix/volumes/volume-postgres
mkdir -p ~/signomix/volumes/volume-ps/logs
mkdir -p ~/signomix/volumes/volume-service/db
mkdir -p ~/signomix/volumes/volume-service/logs
mkdir -p ~/signomix/volumes/volume-service/files
mkdir -p ~/signomix/volumes/volume-service/backup
mkdir -p ~/signomix/volumes/volume-proxy