#!/bin/bash

################################
## CONFIGURATION
##

# versions
versionApp=1.0.4
versionAccount=1.0.4
versionDb=1.0.5
versionMain=1.2.225
versionMs=1.0.3
versionProvider=0.0.1
versionProxy=1.1.3
versionPs=1.0.2.10
versionReceiver=1.0.0

# names
imageNameApp=signomix-ta-app
imageNameAccount=signomix-ta-account
imageNameDb=signomix-database
imageNameMain=signomix
imageNameMs=signomix-ta-ms
imageNameProvider=signomix-ta-provider
imageNameProxy=signomix-proxy
imageNamePs=signomix-ta-ps
imageNameReceiver=signomix-ta-receiver

## proxy config
# domain [mydomain.com | localhost ]
signomixDomain=mydomain.com
statusPage=https://status.mydomain.com
dbpassword=signomixdbpwd

# repository
dockerRepository=

# the above variables can be overridden by local configuration
cfg_location="$1"
echo "$1"
if [ -z "$cfg_location" ]
then
    # default configuration
    cfg_location=local/build-images.cfg
fi
if [ -f "$cfg_location" ]
then
    echo "Building Signomix using configuration from "$cfg_location":"
    . "$cfg_location"
else
    echo "Building Signomix using default config:"
fi

# print config
echo
echo "versionApp=$versionApp"
echo "versionAccount=$versionAccount"
echo "versionDb=$versionDb"
echo "versionMain=$versionMain"
echo "versionMs=$versionMs"
echo "versionProvider=$versionProvider"
echo "versionProxy=$versionProxy"
echo "versionPs=$versionPs"
echo "versionReceiver=$versionReceiver"
echo
echo "imageNameApp=$imageNameApp"
echo "imageNameAccount=$imageNameAccount"
echo "imageNameDb=$imageNameDb"
echo "imageNameMain=$imageNameMain"
echo "imageNameMs=$imageNameMs"
echo "imageNameProvider=$imageNameProvider"
echo "imageNameProxy=$imageNameProxy"
echo "imageNamePs=$imageNamePs"
echo "imageNameReceiver=$imageNameReceiver"
echo
echo "signomixDomain=$signomixDomain"
echo "statusPage=$statusPage"
echo "dockerRepository=$dockerRepository"
echo "dbpassword=$dbpassword"
echo "SIGNOMIX_TITLE=$SIGNOMIX_TITLE"

##
## end CONFIGURATION
##################################

read -p "Do you want to proceed? (yes/no) " yn
case $yn in 
	yes ) echo ok, building ...;;
	no ) echo exiting...;
		exit;;
	* ) echo invalid response;
        echo exiting...;
		exit 1;;
esac

# set env variables
export SIGNOMIX_IMAGE_GROUP=$dockerRepository
export SIGNOMIX_STATUSPAGE_URL=$statusPage

# signomix-proxy
cd ../signomix-proxy
if [ -z "$dockerRepository" ]
then
    docker build --build-arg DOMAIN=$signomixDomain -t $imageNameProxy:$versionProxy .
else
    docker build --build-arg DOMAIN=$signomixDomain -t "$dockerRepository"/$imageNameProxy:$versionProxy .
    docker push "$dockerRepository"/$imageNameProxy:$versionProxy
fi

# signomix-database
cd ../signomix-database
if [ -z "$dockerRepository" ]
then
    docker build --build-arg dbpassword=$dbpassword -t $imageNameDb:$versionDb .
else
    docker build --build-arg dbpassword=$dbpassword -t "$dockerRepository"/$imageNameDb:$versionDb .
    docker push "$dockerRepository"/$imageNameDb:$versionDb
fi
echo

# signomix-main
cd ../signomix
./mvnw versions:set -DnewVersion=$versionMain
mvn package
if [ -z "$dockerRepository" ]
then
    docker build -t $imageNameMain:$versionMain .
else
    docker build -t "$dockerRepository"/$imageNameMain:$versionMain .
    docker push $dockerRepository/$imageNameMain:$versionMain
fi
echo

# signomix-ta-ps
cd ../signomix-ta-ps
./update-webapps.sh
./mvnw versions:set -DnewVersion=$versionPs
if [ -z "$dockerRepository" ]
then
    ./mvnw clean package -DSIGNOMIX_IMAGE_NAME=$imageNamePs -DSIGNOMIX_IMAGE_TAG=$versionPs -Dquarkus.container-image.build=true
else
    ./mvnw clean package -DQUARKUS_CONTAINER_IMAGE_REGISTRY=$dockerRepository -DSIGNOMIX_IMAGE_NAME=$imageNamePs -DSIGNOMIX_IMAGE_TAG=$versionPs -Dquarkus.container-image.push=true
fi
echo

# signomix-ta-app
cd ../signomix-ta-app
./mvnw versions:set -DnewVersion=$versionApp
if [ -z "$dockerRepository" ]
then
    ./mvnw clean package -DSIGNOMIX_IMAGE_NAME=$imageNameApp -DSIGNOMIX_IMAGE_TAG=$versionApp -Dquarkus.container-image.build=true
else
    ./mvnw clean package -DQUARKUS_CONTAINER_IMAGE_REGISTRY=$dockerRepository -DSIGNOMIX_IMAGE_NAME=$imageNameApp -DSIGNOMIX_IMAGE_TAG=$versionApp -Dquarkus.container-image.push=true
fi
echo

# signomix-ta-ms
cd ../signomix-ta-ms
./mvnw versions:set -DnewVersion=$versionMs
if [ -z "$dockerRepository" ]
then
    ./mvnw clean package -DSIGNOMIX_IMAGE_NAME=$imageNameMs -DSIGNOMIX_IMAGE_TAG=$versionMs -Dquarkus.container-image.build=true
else
    ./mvnw clean package -DQUARKUS_CONTAINER_IMAGE_REGISTRY=$dockerRepository -DSIGNOMIX_IMAGE_NAME=$imageNameMs -DSIGNOMIX_IMAGE_TAG=$versionMs -Dquarkus.container-image.push=true
fi
echo

# signomix-ta-receiver
cd ../signomix-ta-receiver
./mvnw versions:set -DnewVersion=$versionReceiver
if [ -z "$dockerRepository" ]
then
    ./mvnw clean package -DSIGNOMIX_IMAGE_NAME=$imageNameReceiver -DSIGNOMIX_IMAGE_TAG=$versionReceiver -Dquarkus.container-image.build=true
else
    ./mvnw clean package -DQUARKUS_CONTAINER_IMAGE_REGISTRY=$dockerRepository -DQUARKUS_CONTAINER_IMAGE_REGISTRY=$dockerRepository -DSIGNOMIX_IMAGE_NAME=$imageNameReceiver -DSIGNOMIX_IMAGE_TAG=$versionReceiver -Dquarkus.container-image.push=true
fi
echo

# signomix-ta-provider
cd ../signomix-ta-provider
./mvnw versions:set -DnewVersion=$versionProvider
if [ -z "$dockerRepository" ]
then
    ./mvnw clean package -DSIGNOMIX_IMAGE_NAME=$imageNameProvider -DSIGNOMIX_IMAGE_TAG=$versionProvider -Dquarkus.container-image.build=true
else
    ./mvnw clean package -DQUARKUS_CONTAINER_IMAGE_REGISTRY=$dockerRepository -DQUARKUS_CONTAINER_IMAGE_REGISTRY=$dockerRepository -DSIGNOMIX_IMAGE_NAME=$imageNameProvider -DSIGNOMIX_IMAGE_TAG=$versionProvider -Dquarkus.container-image.push=true
fi
echo

# signomix-ta-account
cd ../signomix-ta-account
./mvnw versions:set -DnewVersion=$versionAccount
if [ -z "$dockerRepository" ]
then
    ./mvnw clean package -DSIGNOMIX_IMAGE_NAME=$imageNameAccount -DSIGNOMIX_IMAGE_TAG=$versionAccount -Dquarkus.container-image.build=true
else
    ./mvnw clean package -DQUARKUS_CONTAINER_IMAGE_REGISTRY=$dockerRepository -DSIGNOMIX_IMAGE_NAME=$imageNameAccount -DSIGNOMIX_IMAGE_TAG=$versionAccount -Dquarkus.container-image.push=true
fi
echo

# saving images
cd ../signomix-ta
if [ -z "$dockerRepository" ]
then
    mkdir local-images
    rm local-images/*
    docker save $imageNameAccount:$versionAccount | gzip > local-images/$imageNameAccount.tar.gz
    docker save $imageNameApp:$versionApp | gzip > local-images/$imageNameApp.tar.gz
    docker save $imageNameDb:$versionDb | gzip > local-images/$imageNameDb.tar.gz
    docker save $imageNameMain:$versionMain | gzip > local-images/$imageNameMain.tar.gz
    docker save $imageNameMs:$versionMs | gzip > local-images/$imageNameMs.tar.gz
    docker save $imageNameProxy:$versionProxy | gzip > local-images/$imageNameProxy.tar.gz
    docker save $imageNamePs:$versionPs | gzip > local-images/$imageNamePs.tar.gz
    docker save $imageNameReceiver:$versionReceiver | gzip > local-images/$imageNameReceiver.tar.gz
    docker save $imageNameProvider:$versionProvider | gzip > local-images/$imageNameProvider.tar.gz
fi
# done

