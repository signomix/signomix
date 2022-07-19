#!/bin/sh

###  env variables
export SIGNOMIX_GA_TRACKING_ID=NONE
export SIGNOMIX_STATUSPAGE_URL=/

signomixDomain=localhost
statusPage=/
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

# printing config
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

### signomix
cd ../signomix
mvn clean package

### signomix-ta-ps
cd ../signomix-ta-ps
cd src/main/webapp/home
npm install
npm run build
cd ../blog
npm install
npm run build
cd ../../../..
sh update-webapps.sh
./mvnw clean package

### signomix-ta-app
cd ../signomix-ta-app
sh update-webapps.sh
./mvnw clean package

### signomix-ta-ms
cd ../signomix-ta-ms
./mvnw clean package

### signomix-ta-receiver
cd ../signomix-ta-receiver
./mvnw clean package

### signomix-ta-account
cd ../signomix-ta-account
./mvnw clean package

cd ../signomix-ta
docker-compose build