#!/bin/sh

# Update Signomix repositories
cd ../signomix-ta-account
git pull
cd ../signomix-apigateway
git pull
cd ../signomix-ta-app
git pull
cd ../signomix-auth
git pull
cd ../signomix-common
git pull
cd ../signomix-docs-website
git pull
cd ../signomix-ta-core
git pull
cd ../signomix-ta-jobs
git pull
cd ../signomix-ta-ms
git pull
cd ../signomix-ta-provider
git pull
cd ../signomix-ta-receiver
git pull
cd ../signomix-reports
git pull
cd ../signomix-sentinel
git pull
cd ../signomix-webapp
git pull
cd ../signomix-view
git pull
cd ..
