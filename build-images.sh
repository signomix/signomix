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
versionProxy=1.1.3
versionPs=1.0.2.10
versionReceiver=1.0.0

# names
imageNameApp=signomix-ta-app
imageNameAccount=signomix-ta-account
imageNameDb=signomix-database
imageNameMain=signomix
imageNameMs=signomix-ta-ms
imageNameProxy=signomix-proxy
imageNamePs=signomix-ta-ps
imageNameReceiver=signomix-ta-receiver

## proxy config
# domain [mydomain.com | localhost ]
signomixDomain=mydomain.com
statusPage=https://status.mydomain.com

# repository
dockerRepository=

# the above variables can be overridden by local configuration
source local/build-images.cfg


# printing config
echo "Building Signomix using the configuration:"
echo
echo "versionApp=$versionApp"
echo "versionAccount=$versionAccount"
echo "versionDb=$versionDb"
echo "versionMain=$versionMain"
echo "versionMs=$versionMs"
echo "versionProxy=$versionProxy"
echo "versionPs=$versionPs"
echo "versionReceiver=$versionReceiver"
echo
echo "imageNameApp=$imageNameApp"
echo "imageNameAccount=$imageNameAccount"
echo "imageNameDb=$imageNameDb"
echo "imageNameMain=$imageNameMain"
echo "imageNameMs=$imageNameMs"
echo "imageNameProxy=$imageNameProxy"
echo "imageNamePs=$imageNamePs"
echo "imageNameReceiver=$imageNameReceiver"
echo
echo "signomixDomain=$signomixDomain"
echo "statusPage=$statusPage"
echo "dockerRepository=$dockerRepository"

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
    docker build -t $imageNameDb:$versionDb .
else
    docker build -t "$dockerRepository"/$imageNameDb:$versionDb .
    docker push "$dockerRepository"/$imageNameDb:$versionDb
fi
echo

# signomix-main
cd ../signomix
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
if [ -z "$dockerRepository" ]
then
    ./mvnw clean package -Dsignomix_image_name=$imageNamePs -Dquarkus.container-image.build=true
else
    ./mvnw clean package -Dsignomix_image_name=$imageNamePs -Dquarkus.container-image.push=true
fi
echo

# signomix-ta-app
cd ../signomix-ta-app
if [ -z "$dockerRepository" ]
then
    ./mvnw clean package -Dsignomix_image_name=$imageNameApp -Dquarkus.container-image.build=true
else
    ./mvnw clean package -Dsignomix_image_name=$imageNameApp -Dquarkus.container-image.push=true
fi
echo

# signomix-ta-ms
cd ../signomix-ta-ms
if [ -z "$dockerRepository" ]
then
    ./mvnw clean package -Dsignomix_image_name=$imageNameMs -Dquarkus.container-image.build=true
else
    ./mvnw clean package -Dsignomix_image_name=$imageNameMs -Dquarkus.container-image.push=true
fi
echo

# signomix-ta-receiver
cd ../signomix-ta-receiver
if [ -z "$dockerRepository" ]
then
    ./mvnw clean package -Dsignomix_image_name=$imageNameReceiver -Dquarkus.container-image.build=true
else
    ./mvnw clean package -Dsignomix_image_name=$imageNameReceiver -Dquarkus.container-image.push=true
fi
echo

# signomix-ta-account
cd ../signomix-ta-account
if [ -z "$dockerRepository" ]
then
    ./mvnw clean package -Dsignomix_image_name=$imageNameAccount -Dquarkus.container-image.build=true
else
    ./mvnw clean package -Dsignomix_image_name=$imageNameAccount -Dquarkus.container-image.push=true
fi
echo

# saving images
if [ -z "$dockerRepository" ]
then
    docker save $imageNameAccount:$versionAccount | gzip > local-images/$imageNameAccount-$versionAccount.tar.gz
    docker save $imageNameApp:$versionApp | gzip > local-images/$imageNameApp-$versionApp.tar.gz
    docker save $imageNameDb:$versionDb | gzip > local-images/$imageNameDb-$versionDb.tar.gz
    docker save $imageNameMain:$versionMain | gzip > local-images/$imageNameMain-$versionMain.tar.gz
    docker save $imageNameMs:$versionMs | gzip > local-images/$imageNameMs-$versionMs.tar.gz
    docker save $imageNameProxy:$versionProxy | gzip > local-images/$imageNameProxy-$versionProxy.tar.gz
    docker save $imageNamePs:$versionPs | gzip > local-images/$imageNamePs-$versionPs.tar.gz
    docker save $imageNameReceiver:$versionReceiver | gzip > local-images/$imageNameReceiver-$versionReceiver.tar.gz
fi
# done
cd ../signomix-ta
