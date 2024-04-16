#!/bin/bash

# This script is used to create a release summary file that contains the short git commit hash for each service and its version.

SGX_RELEASE_REPO_NAME=signomix
SGX_RELEASE_VERSION=1.0.0

# names
SGX_APP_NAME=signomix-ta-app
SGX_ACCOUNT_NAME=signomix-ta-account
SGX_AUTH_NAME=signomix-auth
SGX_COMMON_NAME=signomix-common
SGX_CORE_NAME=signomix-ta-core
SGX_DOCS_NAME=signomix-docs-website
SGX_GATEWAY_NAME=signomix-gateway
SGX_HCMS_NAME=cricket-hcms
SGX_JOBS_NAME=signomix-ta-jobs
SGX_LB_NAME=signomix-lb
SGX_MS_NAME=signomix-ta-ms
SGX_PROVIDER_NAME=signomix-ta-provider
SGX_RECEIVER_NAME=signomix-ta-receiver
SGX_REPORTS_NAME=signomix-reports
SGX_SENTINEL_NAME=signomix-sentinel
SGX_VIEW_NAME=signomix-view
SGX_WEBAPP_NAME=signomix-webapp
SGX_WEBSITE_NAME=signomix-website

SGX_APP_VERSION=1.0.0
SGX_ACCOUNT_VERSION=1.0.1
SGX_AUTH_VERSION=1.0.2
SGX_COMMON_VERSION=1.0.3
SGX_CORE_VERSION=1.0.4
SGX_DOCS_VERSION=1.0.5
SGX_GATEWAY_VERSION=1.0.6
SGX_HCMS_VERSION=1.0.7
SGX_JOBS_VERSION=1.0.8
SGX_LB_VERSION=1.0.9
SGX_MS_VERSION=1.0.10
SGX_PROVIDER_VERSION=1.0.11
SGX_RECEIVER_VERSION=1.0.12
SGX_REPORTS_VERSION=1.0.13
SGX_SENTINEL_VERSION=1.0.14
SGX_VIEW_VERSION=1.0.15
SGX_WEBAPP_VERSION=1.0.16
SGX_WEBSITE_VERSION=1.0.17

# the above variables can be overridden by local configuration
cfg_location="$1"
echo "cfg_location=$1"
if [ -z "$cfg_location" ]
then
    # default configuration
    cfg_location=dev.env
fi
if [ -f "$cfg_location" ]
then
    echo "Building Signomix using configuration from "$cfg_location":"
    . "$cfg_location"
else
    echo "Building Signomix using default config:"
fi

# Define an array of directories
java_services="$SGX_ACCOUNT_NAME $SGX_APP_NAME $SGX_AUTH_NAME $SGX_COMMON_NAME $SGX_CORE_NAME $SGX_DOCS_NAME $SGX_GATEWAY_NAME"
java_services="$java_services $SGX_HCMS_NAME $SGX_JOBS_NAME $SGX_LB_NAME $SGX_MS_NAME $SGX_PROVIDER_NAME"
java_services="$java_services $SGX_RECEIVER_NAME $SGX_REPORTS_NAME $SGX_SENTINEL_NAME $SGX_VIEW_NAME $SGX_WEBAPP_NAME $SGX_WEBSITE_NAME"

services_versions="$SGX_APP_VERSION $SGX_ACCOUNT_VERSION $SGX_AUTH_VERSION $SGX_COMMON_VERSION $SGX_CORE_VERSION $SGX_DOCS_VERSION $SGX_GATEWAY_VERSION"
services_versions="$services_versions $SGX_HCMS_VERSION $SGX_JOBS_VERSION $SGX_LB_VERSION $SGX_MS_VERSION $SGX_PROVIDER_VERSION"
services_versions="$services_versions $SGX_RECEIVER_VERSION $SGX_REPORTS_VERSION $SGX_SENTINEL_VERSION $SGX_VIEW_VERSION $SGX_WEBAPP_VERSION $SGX_WEBSITE_VERSION"

# Clear the release-summary.txt file
> ../signomix/release-summary.txt
# Insert date and time of generation as UTC date
echo "#$(date --iso-8601=minutes -u)" >> ../signomix/release-summary.txt
# Echo the first line of the config file
head_line=$(head -n 1 $cfg_location)
head_line="${head_line:1}"
echo "#$head_line" >> ../signomix/release-summary.txt
# CSV header
echo "#service;commit hash;version" >> ../signomix/release-summary.txt

# Convert services_versions into an array
read -a services_versions_array <<< "$services_versions"

cd ../$SGX_RELEASE_REPO_NAME
# Get the short git commit hash
hash=$(git rev-parse --short HEAD)
# Echo the directory and hash to the release-summary.txt file
echo "signomix;$hash;$SGX_RELEASE_VERSION" >> ../signomix/release-summary.txt

# Loop over the directories
counter=0
dir_exists=false
for dir in $java_services; do
    dir_exists=false
    # Change to the directory
    if [ "$dir" = "signomix-lb" ]; then
        if [ -d "../signomix-proxy2" ]; then
            cd "../signomix-proxy2" 2>/dev/null
            dir_exists=true
        else
            dir_exists=false
        fi
    elif [ "$dir" = "signomix-gateway" ]; then
        if [ -d "../signomix-apigateway" ]; then
            cd "../signomix-apigateway" 2>/dev/null
            dir_exists=true
        else
            dir_exists=false
        fi
    else
        cd "../$dir"
        dir_exists=true
    fi
    if [ "$dir_exists" = true ]; then
        # Get the short git commit hash
        hash=$(git rev-parse --short HEAD)
        # Echo the directory and hash to the release-summary.txt file
        echo "$dir;$hash;${services_versions_array[counter]}" >> ../signomix/release-summary.txt
        # Increment the counter
    fi
    ((counter++))
done