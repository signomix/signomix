#!/bin/bash

################################
## CONFIGURATION
##

# versions
versionApp=1.0.4
versionAccount=1.0.4
versionAuth=1.0.0
versionDb=1.0.5
versionMain=1.2.225
versionMs=1.0.3
versionProvider=0.0.1
versionProxy=1.1.3
versionPs=1.0.2.10
versionReceiver=1.0.0
versionCore=1.0.0
versionJobs=1.0.0
versionDocsWebsite=1.0.0
versionHcms=1.0.0
orderformUrlPl=https://orderform.mydomain.com/pl
orderformUrlEn=https://orderform.mydomain.com/en

# names
imageNameApp=signomix-ta-app
imageNameAccount=signomix-ta-account
imageNameAuth=signomix-auth
imageNameDb=signomix-database
imageNameMain=signomix
imageNameMs=signomix-ta-ms
imageNameProvider=signomix-ta-provider
imageNameProxy=signomix-proxy
imageNamePs=signomix-ta-ps
imageNameReceiver=signomix-ta-receiver
imageNameCore=signomix-ta-core
imageNameJobs=signomix-ta-jobs
imageNameDocsWebsite=signomix-docs-website
imageNameHcms=cricket-hcms

## proxy config
# domain [mydomain.com | localhost ]
signomixDomain=mydomain.com
statusPage=https://status.mydomain.com
dbpassword=signomixdbpwd

# repository
dockerRegistry=
dockerHubType=true
exportImages=true

# other
defaultOrganizationId=0


# the above variables can be overridden by local configuration
cfg_location="$1"
echo "cfg_location=$1"
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
echo "versionAuth=$versionAuth"
echo "versionCommon=$versionCommon"
cat ../signomix-common/pom.xml|grep versionCommon
echo "versionDb=$versionDb"
echo "versionMain=$versionMain"
echo "versionMs=$versionMs"
echo "versionProvider=$versionProvider"
echo "versionProxy=$versionProxy"
echo "versionPs=$versionPs"
echo "versionReceiver=$versionReceiver"
echo "versionCore=$versionCore"
echo "versionJobs=$versionJobs"
echo "versionDocsWebsite=$versionDocsWebsite"
echo "versionHcms=$versionHcms"
echo
echo "imageNameApp=$imageNameApp"
echo "imageNameAccount=$imageNameAccount"
echo "imageNameAuth=$imageNameAuth"
echo "imageNameDb=$imageNameDb"
echo "imageNameMain=$imageNameMain"
echo "imageNameMs=$imageNameMs"
echo "imageNameProvider=$imageNameProvider"
echo "imageNameProxy=$imageNameProxy"
echo "imageNamePs=$imageNamePs"
echo "imageNameReceiver=$imageNameReceiver"
echo "imageNameCore=$imageNameCore"
echo "imageNameJobs=$imageNameJobs"
echo "imageNameDocsWebsite=$imageNameDocsWebsite"
echo "imageNameHcms=$imageNameHcms"
echo
echo "signomixDomain=$signomixDomain"
echo "statusPage=$statusPage"
echo "dockerHubType=$dockerHubType"
echo "dockerRegistry=$dockerRegistry"
echo "dockerGroup=$dockerGroup"
echo "dockerUser=$dockerUser"
echo "dockerPassword=$dockerPassword"
echo "dbpassword=$dbpassword"
echo "withGraylog=$withGraylog"
echo "exportImages=$exportImages"
echo "orderformUrlPl=$orderformUrlPl"
echo "orderformUrlEn=$orderformUrlEn"
echo "SIGNOMIX_TITLE=$SIGNOMIX_TITLE"
echo "defaultOrganizationId=$defaultOrganizationId"
echo
echo "Image filter: $2"

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

if [ -z "$2" ] || [ "$2" = "signomix-webapp" ]; then
# signomix-webapp
cd ../signomix-webapp
npm run build
retVal=$?
if [ $retVal -ne 0 ]; then
    exit $retval
fi
rm -R ../signomix-proxy/webapp/*
cp -R build/* ../signomix-proxy/webapp
fi

if [ -z "$2" ] || [ "$2" = "signomix-proxy" ] || [ "$2" = "signomix-webapp" ]; then
# signomix-proxy
cd ../signomix-proxy
if [ $withGraylog = "true" ]
then
    cp nginx-with-graylog.conf nginx.conf
else
    cp nginx-no-graylog.conf nginx.conf
fi

if [ -z "$dockerRegistry" ]
then
    docker build --build-arg DOMAIN=$signomixDomain -t $imageNameProxy:$versionProxy .
else
    if [ $dockerHubType = "true" ]
    then
    docker build --build-arg DOMAIN=$signomixDomain -t $dockerUser/$imageNameProxy:$versionProxy .
    docker push $dockerUser/$imageNameProxy:$versionProxy
    else
    docker build --build-arg DOMAIN=$signomixDomain -t $dockerRegistry/$dockerGroup/$imageNameProxy:$versionProxy .
    docker push $dockerRegistry/$dockerGroup/$imageNameProxy:$versionProxy
    fi
fi
retVal=$?
if [ $retVal -ne 0 ]; then
    exit $retval
fi
echo
fi

if [ -z "$2" ] || [ "$2" = "signomix-database" ]; then
# signomix-database
cd ../signomix-database
if [ -z "$dockerRegistry" ]
then
    docker build --build-arg dbpassword=$dbpassword -t $imageNameDb:$versionDb .
else
    if [ $dockerHubType = "true" ]
    then
    docker build --build-arg dbpassword=$dbpassword -t $dockerUser/$imageNameDb:$versionDb .
    docker push $dockerUser/$imageNameDb:$versionDb
    else
    docker build --build-arg dbpassword=$dbpassword -t $dockerRegistry/$dockerGroup/$imageNameDb:$versionDb .
    docker push $dockerRegistry/$dockerGroup/$imageNameDb:$versionDb
    fi
fi
retVal=$?
if [ $retVal -ne 0 ]; then
    exit $retval
fi
echo
fi

### signomix-common
cd ../signomix-common
mvn versions:set -DnewVersion=$versionCommon
mvn clean install
retVal=$?
if [ $retVal -ne 0 ]; then
    exit $retval
fi

if [ -z "$2" ] || [ "$2" = "signomix-ta-jobs" ]; then
### signomix-jobs
cd ../signomix-ta-jobs
./mvnw versions:set -DnewVersion=$versionJobs
retVal=$?
if [ $retVal -ne 0 ]; then
    exit $retval
fi
if [ -z "$dockerRegistry" ]
then
    echo
    ./mvnw \
    -Dquarkus.container-image.name=$imageNameJobs \
    -Dquarkus.container-image.tag=$versionJobs \
    -Dquarkus.container-image.build=true \
    clean package
else
    if [ $dockerHubType = "true" ]
    then
    ./mvnw \
    -Dquarkus.container-image.group=$dockerGroup \
    -Dquarkus.container-image.name=$imageNameJobs \
    -Dquarkus.container-image.tag=$versionJobs \
    -Dquarkus.container-image.push=true \
    clean package
    else
        ./mvnw \
    -Dquarkus.container-image.registry=$dockerRegistry \
    -Dquarkus.container-image.group=$dockerGroup \
    -Dquarkus.container-image.username=$dockerUser \
    -Dquarkus.container-image.password=$dockerPassword \
    -Dquarkus.container-image.name=$imageNameJobs \
    -Dquarkus.container-image.tag=$versionJobs \
    -Dquarkus.container-image.push=true \
    clean package
    fi
fi
retVal=$?
if [ $retVal -ne 0 ]; then
    exit $retval
fi
fi

if [ -z "$2" ] || [ "$2" = "signomix-ta-core" ]; then
### signomix-core
cd ../signomix-ta-core
./mvnw versions:set -DnewVersion=$versionCore
retVal=$?
if [ $retVal -ne 0 ]; then
    exit $retval
fi
if [ -z "$dockerRegistry" ]
then
    echo
    ./mvnw \
    -Dquarkus.container-image.name=$imageNameCore \
    -Dquarkus.container-image.tag=$versionCore \
    -Dquarkus.container-image.build=true \
    clean package
else
    if [ $dockerHubType = "true" ]
    then
    ./mvnw \
    -Dquarkus.container-image.group=$dockerGroup \
    -Dquarkus.container-image.name=$imageNameCore \
    -Dquarkus.container-image.tag=$versionCore \
    -Dquarkus.container-image.push=true \
    clean package
    else
    ./mvnw \
    -Dquarkus.container-image.registry=$dockerRegistry \
    -Dquarkus.container-image.group=$dockerGroup \
    -Dquarkus.container-image.username=$dockerUser \
    -Dquarkus.container-image.password=$dockerPassword \
    -Dquarkus.container-image.name=$imageNameCore \
    -Dquarkus.container-image.tag=$versionCore \
    -Dquarkus.container-image.push=true \
    clean package
    fi
fi
retVal=$?
if [ $retVal -ne 0 ]; then
    exit $retval
fi
fi

if [ -z "$2" ] || [ "$2" = "signomix-auth" ]; then
### signomix-auth
cd ../signomix-auth
./mvnw versions:set -DnewVersion=$versionAuth
retVal=$?
if [ $retVal -ne 0 ]; then
    exit $retval
fi
if [ -z "$dockerRegistry" ]
then
    echo
    ./mvnw \
    -Dquarkus.container-image.name=$imageNameAuth \
    -Dquarkus.container-image.tag=$versionAuth \
    -Dquarkus.container-image.build=true \
    clean package
else
    if [ $dockerHubType = "true" ]
    then
    ./mvnw \
    -Dquarkus.container-image.group=$dockerGroup \
    -Dquarkus.container-image.name=$imageNameAuth \
    -Dquarkus.container-image.tag=$versionAuth \
    -Dquarkus.container-image.push=true \
    clean package
    else
    ./mvnw \
    -Dquarkus.container-image.registry=$dockerRegistry \
    -Dquarkus.container-image.group=$dockerGroup \
    -Dquarkus.container-image.username=$dockerUser \
    -Dquarkus.container-image.password=$dockerPassword \
    -Dquarkus.container-image.name=$imageNameAuth \
    -Dquarkus.container-image.tag=$versionAuth \
    -Dquarkus.container-image.push=true \
    clean package
    fi
fi
retVal=$?
if [ $retVal -ne 0 ]; then
    exit $retval
fi
fi

if [ -z "$2" ] || [ "$2" = "signomix-main" ]; then
# signomix-main
cd ../signomix
./mvnw versions:set -DnewVersion=$versionMain
mvn package
retVal=$?
if [ $retVal -ne 0 ]; then
    exit $retval
fi
if [ -z "$dockerRegistry" ]
then
    docker build -t $imageNameMain:$versionMain .
else
    if [ $dockerHubType = "true" ]
    then
    docker build -t $dockerUser/$imageNameMain:$versionMain .
    docker push $dockerUser/$imageNameMain:$versionMain
    else
    docker build -t $dockerRegistry/$dockerGroup/$imageNameMain:$versionMain .
    docker push $dockerRegistry/$dockerGroup/$imageNameMain:$versionMain
    fi
fi
retVal=$?
if [ $retVal -ne 0 ]; then
    exit $retval
fi
echo
fi

if [ -z "$2" ] || [ "$2" = "signomix-ta-ps" ]; then
# signomix-ta-ps
cd ../signomix-ta-ps
./update-webapps.sh
./mvnw versions:set -DnewVersion=$versionPs
retVal=$?
if [ $retVal -ne 0 ]; then
    exit $retval
fi
if [ -z "$dockerRegistry" ]
then
    echo
    ./mvnw \
    -Dquarkus.container-image.name=$imageNamePs \
    -Dquarkus.container-image.tag=$versionPs \
    -Dquarkus.container-image.build=true \
    clean package
else
    if [ $dockerHubType = "true" ]
    then
    ./mvnw \
    -Dquarkus.container-image.group=$dockerGroup \
    -Dquarkus.container-image.name=$imageNamePs \
    -Dquarkus.container-image.tag=$versionPs \
    -Dquarkus.container-image.push=true \
    clean package
    else
    ./mvnw \
    -Dquarkus.container-image.registry=$dockerRegistry \
    -Dquarkus.container-image.group=$dockerGroup \
    -Dquarkus.container-image.username=$dockerUser \
    -Dquarkus.container-image.password=$dockerPassword \
    -Dquarkus.container-image.name=$imageNamePs \
    -Dquarkus.container-image.tag=$versionPs \
    -Dquarkus.container-image.push=true \
    clean package
    fi
fi
retVal=$?
if [ $retVal -ne 0 ]; then
    exit $retval
fi
echo
fi

if [ -z "$2" ] || [ "$2" = "signomix-ta-app" ]; then
# signomix-ta-app
cd ../signomix-ta-app
./mvnw versions:set -DnewVersion=$versionApp
retVal=$?
if [ $retVal -ne 0 ]; then
    exit $retval
fi
if [ -z "$dockerRegistry" ]
then
    echo
    ./mvnw \
    -DSIGNOMIX_IMAGE_NAME=$imageNameApp \
    -DSIGNOMIX_IMAGE_TAG=$versionApp \
    -Dquarkus.container-image.name=$imageNameApp \
    -Dquarkus.container-image.tag=$versionApp \
    -Dquarkus.container-image.build=true \
    clean package
else
    if [ $dockerHubType = "true" ]
    then
    ./mvnw \
    -DSIGNOMIX_IMAGE_NAME=$imageNameApp \
    -DSIGNOMIX_IMAGE_TAG=$versionApp \
    -Dquarkus.container-image.group=$dockerGroup \
    -Dquarkus.container-image.name=$imageNameApp \
    -Dquarkus.container-image.tag=$versionApp \
    -Dquarkus.container-image.push=true \
    clean package
    else
    ./mvnw \
    -DSIGNOMIX_IMAGE_NAME=$imageNameApp \
    -DSIGNOMIX_IMAGE_TAG=$versionApp \
    -Dquarkus.container-image.registry=$dockerRegistry \
    -Dquarkus.container-image.group=$dockerGroup \
    -Dquarkus.container-image.username=$dockerUser \
    -Dquarkus.container-image.password=$dockerPassword \
    -Dquarkus.container-image.name=$imageNameApp \
    -Dquarkus.container-image.tag=$versionApp \
    -Dquarkus.container-image.push=true \
    clean package
    fi
fi
retVal=$?
if [ $retVal -ne 0 ]; then
    exit $retval
fi
echo
fi

if [ -z "$2" ] || [ "$2" = "signomix-ta-ms" ]; then
# signomix-ta-ms
cd ../signomix-ta-ms
./mvnw versions:set -DnewVersion=$versionMs
retVal=$?
if [ $retVal -ne 0 ]; then
    exit $retval
fi
if [ -z "$dockerRegistry" ]
then
    echo
    ./mvnw \
    -Dquarkus.container-image.name=$imageNameMs \
    -Dquarkus.container-image.tag=$versionMs \
    -Dquarkus.container-image.build=true \
    clean package
else
    if [ $dockerHubType = "true" ]
    then
    ./mvnw \
    -Dquarkus.container-image.group=$dockerGroup \
    -Dquarkus.container-image.name=$imageNameMs \
    -Dquarkus.container-image.tag=$versionMs \
    -Dquarkus.container-image.push=true \
    clean package
    else
    ./mvnw \
    -Dquarkus.container-image.registry=$dockerRegistry \
    -Dquarkus.container-image.group=$dockerGroup \
    -Dquarkus.container-image.username=$dockerUser \
    -Dquarkus.container-image.password=$dockerPassword \
    -Dquarkus.container-image.name=$imageNameMs \
    -Dquarkus.container-image.tag=$versionMs \
    -Dquarkus.container-image.push=true \
    clean package
    fi
fi
retVal=$?
if [ $retVal -ne 0 ]; then
    exit $retval
fi
echo
fi

if [ -z "$2" ] || [ "$2" = "signomix-ta-receiver" ]; then
# signomix-ta-receiver
cd ../signomix-ta-receiver
./mvnw versions:set -DnewVersion=$versionReceiver
retVal=$?
if [ $retVal -ne 0 ]; then
    exit $retval
fi
if [ -z "$dockerRegistry" ]
then
    echo
    ./mvnw \
    -Dquarkus.container-image.name=$imageNameReceiver \
    -Dquarkus.container-image.tag=$versionReceiver \
    -Dquarkus.container-image.build=true \
    clean package
else
    if [ $dockerHubType = "true" ]
    then
    ./mvnw \
    -Dquarkus.container-image.group=$dockerGroup \
    -Dquarkus.container-image.name=$imageNameReceiver \
    -Dquarkus.container-image.tag=$versionReceiver \
    -Dquarkus.container-image.push=true \
    clean package
    else
    ./mvnw \
    -Dquarkus.container-image.registry=$dockerRegistry \
    -Dquarkus.container-image.group=$dockerGroup \
    -Dquarkus.container-image.username=$dockerUser \
    -Dquarkus.container-image.password=$dockerPassword \
    -Dquarkus.container-image.name=$imageNameReceiver \
    -Dquarkus.container-image.tag=$versionReceiver \
    -Dquarkus.container-image.push=true \
    clean package
    fi
fi
retVal=$?
if [ $retVal -ne 0 ]; then
    exit $retval
fi
echo
fi

if [ -z "$2" ] || [ "$2" = "signomix-ta-provider" ]; then
# signomix-ta-provider
cd ../signomix-ta-provider
./mvnw versions:set -DnewVersion=$versionProvider
retVal=$?
if [ $retVal -ne 0 ]; then
    exit $retval
fi
if [ -z "$dockerRegistry" ]
then
    echo
    ./mvnw \
    -Dquarkus.container-image.name=$imageNameProvider \
    -Dquarkus.container-image.tag=$versionProvider \
    -Dquarkus.container-image.build=true \
    clean package
else
    if [ $dockerHubType = "true" ]
    then
    ./mvnw \
    -Dquarkus.container-image.group=$dockerGroup \
    -Dquarkus.container-image.name=$imageNameProvider \
    -Dquarkus.container-image.tag=$versionProvider \
    -Dquarkus.container-image.push=true \
    clean package
    else
    ./mvnw \
    -Dquarkus.container-image.registry=$dockerRegistry \
    -Dquarkus.container-image.group=$dockerGroup \
    -Dquarkus.container-image.username=$dockerUser \
    -Dquarkus.container-image.password=$dockerPassword \
    -Dquarkus.container-image.name=$imageNameProvider \
    -Dquarkus.container-image.tag=$versionProvider \
    -Dquarkus.container-image.push=true \
    clean package
    fi
fi
retVal=$?
if [ $retVal -ne 0 ]; then
    exit $retval
fi
echo
fi

if [ -z "$2" ] || [ "$2" = "signomix-ta-account" ]; then
# signomix-ta-account
cd ../signomix-ta-account
./mvnw versions:set -DnewVersion=$versionAccount
retVal=$?
if [ $retVal -ne 0 ]; then
    exit $retval
fi
if [ -z "$dockerRegistry" ]
then
    echo
    ./mvnw \
    -Dquarkus.container-image.name=$imageNameAccount \
    -Dquarkus.container-image.tag=$versionAccount \
    -Dquarkus.container-image.build=true \
    clean package
else
    if [ $dockerHubType = "true" ]
    then
    ./mvnw \
    -Dquarkus.container-image.group=$dockerGroup \
    -Dquarkus.container-image.name=$imageNameAccount \
    -Dquarkus.container-image.tag=$versionAccount \
    -Dquarkus.container-image.push=true \
    clean package
    else
    ./mvnw \
    -Dquarkus.container-image.registry=$dockerRegistry \
    -Dquarkus.container-image.group=$dockerGroup \
    -Dquarkus.container-image.username=$dockerUser \
    -Dquarkus.container-image.password=$dockerPassword \
    -Dquarkus.container-image.name=$imageNameAccount \
    -Dquarkus.container-image.tag=$versionAccount \
    -Dquarkus.container-image.push=true \
    clean package
    fi
fi
retVal=$?
if [ $retVal -ne 0 ]; then
    exit $retval
fi
echo
fi

# hcms
if [ -z "$2" ] || [ "$2" = "cricket-hcms" ]; then
cd ../cricket-hcms
./mvnw versions:set -DnewVersion=$versionHcms
retVal=$?
if [ $retVal -ne 0 ]; then
    exit $retval
fi
if [ -z "$dockerRegistry" ]
then
    echo
    ./mvnw \
    -Dquarkus.container-image.name=$imageNameHcms \
    -Dquarkus.container-image.tag=$versionHcms \
    -Dquarkus.container-image.additional-tags=latest \
    -Dquarkus.container-image.build=true \
    clean package
else
    if [ $dockerHubType = "true" ]
    then
    ./mvnw \
    -Dquarkus.container-image.group=$dockerGroup \
    -Dquarkus.container-image.name=$imageNameHcms \
    -Dquarkus.container-image.tag=$versionHcms \
    -Dquarkus.container-image.additional-tags=latest \
    -Dquarkus.container-image.push=true \
    clean package
    else
    ./mvnw \
    -Dquarkus.container-image.registry=$dockerRegistry \
    -Dquarkus.container-image.group=$dockerGroup \
    -Dquarkus.container-image.username=$dockerUser \
    -Dquarkus.container-image.password=$dockerPassword \
    -Dquarkus.container-image.name=$imageNameHcms \
    -Dquarkus.container-image.tag=$versionHcms \
    -Dquarkus.container-image.additional-tags=latest \
    -Dquarkus.container-image.push=true \
    clean package
    fi
fi
retVal=$?
if [ $retVal -ne 0 ]; then
    exit $retval
fi
echo
fi

# signomix-docs-website
if [ -z "$2" ] || [ "$2" = "signomix-docs-website" ]; then

cd ../signomix-docs-website
echo "PUBLIC_HCMS_URL = 'https://hcms.$signomixDomain/api/docs'" > .env
echo "PUBLIC_HCMS_INDEX = 'index.md'" >> .env
if [ -z "$dockerRegistry" ]
then
    docker build -t $imageNameDocsWebsite:$versionDocsWebsite .
else
    if [ $dockerHubType = "true" ]
    then
    docker build  -t $dockerUser/$imageNameDocsWebsite:$versionDocsWebsite .
    docker push $dockerUser/$imageNameDocsWebsite:$versionDocsWebsite
    else
    docker build -t $dockerRegistry/$dockerGroup/$imageNameDocsWebsite:$versionDocsWebsite .
    docker push $dockerRegistry/$dockerGroup/$imageNameDocsWebsite:$versionDocsWebsite
    fi
fi
retVal=$?
if [ $retVal -ne 0 ]; then
    exit $retval
fi
echo
fi

# saving images
cd ../signomix-ta
if [ -z "$dockerRegistry" ]
then
    if [ $exportImages != "true" ]
    then
    echo "image export skipped"
    else
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
    docker save $imageNameCore:$versionCore | gzip > local-images/$imageNameCore.tar.gz
    docker save $imageNameJobs:$versionJobs | gzip > local-images/$imageNameJobs.tar.gz
    echo "saved"
    fi
fi
# done

