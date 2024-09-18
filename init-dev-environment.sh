#!/bin/sh

# Script to clone Signomix repositories and create required folders for Docker volumes


# assuming that you have cloned the signomix-ta repository to the `~/workspace/signomix-ta` folder
# and you want to clone all other repositories to `~/workspace` subfolders.
cd ..

# Clone Signomix repositories

# services
git clone https://github.com/signomix/signomix-ta-account.git
git clone https://github.com/signomix/signomix-apigateway.git
#git clone https://github.com/signomix/signomix-ta-app.git
git clone https://github.com/signomix/signomix-auth.git
git clone https://github.com/signomix/signomix-common.git
git clone https://github.com/signomix/signomix-ta-core.git
git clone https://github.com/signomix/signomix-extensions.git

git clone https://github.com/signomix/signomix-ta-jobs.git
git clone https://github.com/signomix/signomix-ta-ms.git
git clone https://github.com/signomix/signomix-ta-provider.git
git clone https://github.com/signomix/signomix-ta-receiver.git
git clone https://github.com/signomix/signomix-reports.git
git clone https://github.com/signomix/signomix-sentinel.git

# webapps
git clone https://github.com/signomix/signomix-webapp.git
git clone https://github.com/signomix/signomix-website.git
git clone https://github.com/signomix/signomix-docs-website.git
git clone https://github.com/signomix/signomix-view.git

# content repositories
git clone https://githb.com/signomix/signomix-documentation.git
git clone https://githb.com/signomix/signomix-doc-templates.git
git clone https://githb.com/signomix/signomix-app-news.git

# Create required folders for Docker volumes
./init-runtime-environment.sh