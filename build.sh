#!/bin/sh

###  env variables
export SIGNOMIX_GA_TRACKING_ID=NONE
export SIGNOMIX_STATUSPAGE_URL=/
export SIGNOMIX_TITLE=Signomix

signomixDomain=localhost
statusPage=/
dbpassword=signomixdbpwd
# the above variables can be overridden by local configuration
env_name="$1"
config_path="$2"
yml_file_name="$3"
echo "Passed arguments:"
echo "1. environment:" "$1"
echo "2. config folder" "$2"
echo "3. compose yml file:" "$3"

cfg_file="$2"/"$1".cfg
env_file="$2"/"$1".env
yml_file="$2"/"$yml_file_name"

if [ -z "$env_file" ]
then
    # default yml
    env_file=.env
    config_path=.
fi
if [ -z "$yml_file" ]
then
    # default yml
    yml_file=docker_compose.yml
    config_path=.
fi

if [ -z "$cfg_file" ]
then
    # default configuration
    env_name=dev
    config_path=.
fi
if [ -f "$cfg_file" ]
then
    echo "Building Signomix using configuration from "$cfg_file
    . "$cfg_file"
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
# docker-compose --project-directory . --env-file local/dev.env -f local/docker-compose.yml build

docker-compose --project-directory . --env-file "$env_file" -f "$yml_file" build