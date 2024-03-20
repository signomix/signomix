#!/bin/bash

# Script to build Signomix images

################################
## CONFIGURATION
##

# versions
versionApp=1.0.4
versionAccount=1.0.4
versionAuth=1.0.0
versionCommon=1.0.0
versionMs=1.0.3
versionProvider=0.0.1
versionLb=1.0.0
versionGateway=1.0.0
versionReceiver=1.0.0
versionCore=1.0.0
versionJobs=1.0.0
versionDocsWebsite=1.0.0
versionView=1.0.0
versionWebapp=1.0.0
versionSentinel=1.0.0
versionHcms=1.0.0
versionWebsite=1.0.0
versionWebsiteHcms=1.0.0
versionReports=1.0.0
orderformUrlPl=https://orderform.mydomain.com/pl
orderformUrlEn=https://orderform.mydomain.com/en

# names
imageNameApp=signomix-ta-app
imageNameAccount=signomix-ta-account
imageNameAuth=signomix-auth
imageNameMs=signomix-ta-ms
imageNameProvider=signomix-ta-provider
imageNameGateway=signomix-gateway
imageNameLb=signomix-lb
imageNameReceiver=signomix-ta-receiver
imageNameCore=signomix-ta-core
imageNameJobs=signomix-ta-jobs
imageNameDocsWebsite=signomix-docs-website
imageNameHcms=cricket-hcms
imageNameView=signomix-view
imageNameSentinel=signomix-sentinel
imageNameWebapp=signomix-webapp
imageNameWebsite=signomix-website
imageNameWebsiteHcms=signomix-website-hcms
imageNameReports=signomix-reports

java_services='signomix-ta-app signomix-ta-account signomix-auth signomix-ta-ms signomix-ta-provider signomix-ta-receiver signomix-ta-core signomix-ta-jobs signomix-sentinel signomix-reports'
build_common_lib=no

for item in $java_services
do
    if [ "$2" = "$item" ]; then
        build_common_lib=yes
    fi
done

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
echo "versionMs=$versionMs"
echo "versionProvider=$versionProvider"
echo "versionReceiver=$versionReceiver"
echo "versionCore=$versionCore"
echo "versionJobs=$versionJobs"
echo "versionDocsWebsite=$versionDocsWebsite"
echo "versionHcms=$versionHcms"
echo "versionView=$versionView"
echo "versionSentinel=$versionSentinel"
echo "versionWebapp=$versionWebapp"
echo "versionWebsite=$versionWebsite"
echo "versionWebsiteHcms=$versionWebsiteHcms"
echo "versionReports=$versionReports"

echo
echo "imageNameApp=$imageNameApp"
echo "imageNameAccount=$imageNameAccount"
echo "imageNameAuth=$imageNameAuth"
echo "imageNameMs=$imageNameMs"
echo "imageNameProvider=$imageNameProvider"
echo "imageNameProxy2=$imageNameProxy2"
echo "imageNameReceiver=$imageNameReceiver"
echo "imageNameCore=$imageNameCore"
echo "imageNameJobs=$imageNameJobs"
echo "imageNameDocsWebsite=$imageNameDocsWebsite"
echo "imageNameHcms=$imageNameHcms"
echo "imageNameView=$imageNameView"
echo "imageNameSentinel=$imageNameSentinel"
echo "imageNameWebapp=$imageNameWebapp"
echo "imageNameWebsite=$imageNameWebsite"
echo "imageNameWebsiteHcms=$imageNameWebsiteHcms"
echo "imageNameReports=$imageNameReports"
echo
echo "signomixDomain=$signomixDomain"
echo "statusPage=$statusPage"
echo "dockerHubType=$dockerHubType"
echo "dockerRegistry=$dockerRegistry"
echo "dockerGroup=$dockerGroup"
echo "dockerUser=$dockerUser"
echo "dockerPassword=$dockerPassword"
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

### signomix-apigateway
if [ -z "$2" ] || [ "$2" = "signomix-gateway" ] || [ "$2" = "signomix-apigateway" ]; then
cd ../signomix-apigateway
if [ -z "$dockerRegistry" ]
then
    docker build --build-arg DOMAIN=$signomixDomain -t $imageNameGateway:$versionGateway -t $imageNameGateway:latest .
else
    if [ $dockerHubType = "true" ]
    then
    docker build --build-arg DOMAIN=$signomixDomain -t $dockerUser/$imageNameGateway:$versionGateway -t $dockerUser/$imageNameGateway:latest .
    docker push $dockerUser/$imageNameGateway:$versionGateway
    docker push $dockerUser/$imageNameGateway:latest
    else
    docker build --build-arg DOMAIN=$signomixDomain -t $dockerRegistry/$dockerGroup/$imageNameGateway:$versionGateway -t $dockerRegistry/$dockerGroup/$imageNameGateway:latest .
    docker push $dockerRegistry/$dockerGroup/$imageNameGateway:$versionGateway
    docker push $dockerRegistry/$dockerGroup/$imageNameGateway:latest
    fi
fi
retVal=$?
if [ $retVal -ne 0 ]; then
    exit $retval
fi
echo
fi

### signomix-common
if [ -z "$2" ] || [ "$build_common_lib" = "yes" ]; 
then
cd ../signomix-common
mvn versions:set -DnewVersion=$versionCommon
mvn clean install
retVal=$?
if [ $retVal -ne 0 ]; then
    exit $retval
fi
fi

### signomix-jobs
if [ -z "$2" ] || [ "$2" = "signomix-ta-jobs" ]; then
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
    -Dquarkus.container-image.additional-tags=latest \
    -Dquarkus.container-image.build=true \
    clean package
else
    if [ $dockerHubType = "true" ]
    then
    ./mvnw \
    -Dquarkus.container-image.group=$dockerGroup \
    -Dquarkus.container-image.name=$imageNameJobs \
    -Dquarkus.container-image.tag=$versionJobs \
    -Dquarkus.container-image.additional-tags=latest \
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
    -Dquarkus.container-image.additional-tags=latest \
    -Dquarkus.container-image.push=true \
    clean package
    fi
fi
retVal=$?
if [ $retVal -ne 0 ]; then
    exit $retval
fi
fi

### signomix-core
if [ -z "$2" ] || [ "$2" = "signomix-ta-core" ]; then
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
    -Dquarkus.container-image.additional-tags=latest \
    -Dquarkus.container-image.build=true \
    clean package
else
    if [ $dockerHubType = "true" ]
    then
    ./mvnw \
    -Dquarkus.container-image.group=$dockerGroup \
    -Dquarkus.container-image.name=$imageNameCore \
    -Dquarkus.container-image.tag=$versionCore \
    -Dquarkus.container-image.additional-tags=latest \
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
    -Dquarkus.container-image.additional-tags=latest \
    -Dquarkus.container-image.push=true \
    clean package
    fi
fi
retVal=$?
if [ $retVal -ne 0 ]; then
    exit $retval
fi
fi

### signomix-auth
if [ -z "$2" ] || [ "$2" = "signomix-auth" ]; then
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
    -Dquarkus.container-image.additional-tags=latest \
    -Dquarkus.container-image.build=true \
    clean package
else
    if [ $dockerHubType = "true" ]
    then
    ./mvnw \
    -Dquarkus.container-image.group=$dockerGroup \
    -Dquarkus.container-image.name=$imageNameAuth \
    -Dquarkus.container-image.tag=$versionAuth \
    -Dquarkus.container-image.additional-tags=latest \
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
    -Dquarkus.container-image.additional-tags=latest \
    -Dquarkus.container-image.push=true \
    clean package
    fi
fi
retVal=$?
if [ $retVal -ne 0 ]; then
    exit $retval
fi
fi

### signomix-ta-app
if [ -z "$2" ] || [ "$2" = "signomix-ta-app" ]; then
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
    -Dquarkus.container-image.additional-tags=latest \
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
    -Dquarkus.container-image.additional-tags=latest \
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

### signomix-ta-ms
if [ -z "$2" ] || [ "$2" = "signomix-ta-ms" ]; then
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
    -Dquarkus.container-image.additional-tags=latest \
    -Dquarkus.container-image.build=true \
    clean package
else
    if [ $dockerHubType = "true" ]
    then
    ./mvnw \
    -Dquarkus.container-image.group=$dockerGroup \
    -Dquarkus.container-image.name=$imageNameMs \
    -Dquarkus.container-image.tag=$versionMs \
    -Dquarkus.container-image.additional-tags=latest \
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

### signomix-ta-receiver
if [ -z "$2" ] || [ "$2" = "signomix-ta-receiver" ]; then
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
    -Dquarkus.container-image.additional-tags=latest \
    -Dquarkus.container-image.build=true \
    clean package
else
    if [ $dockerHubType = "true" ]
    then
    ./mvnw \
    -Dquarkus.container-image.group=$dockerGroup \
    -Dquarkus.container-image.name=$imageNameReceiver \
    -Dquarkus.container-image.tag=$versionReceiver \
    -Dquarkus.container-image.additional-tags=latest \
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

### signomix-ta-provider
if [ -z "$2" ] || [ "$2" = "signomix-ta-provider" ]; then
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
    -Dquarkus.container-image.additional-tags=latest \
    -Dquarkus.container-image.build=true \
    clean package
else
    if [ $dockerHubType = "true" ]
    then
    ./mvnw \
    -Dquarkus.container-image.group=$dockerGroup \
    -Dquarkus.container-image.name=$imageNameProvider \
    -Dquarkus.container-image.tag=$versionProvider \
    -Dquarkus.container-image.additional-tags=latest \
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

### signomix-ta-account
if [ -z "$2" ] || [ "$2" = "signomix-ta-account" ]; then
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
    -Dquarkus.container-image.additional-tags=latest \
    -Dquarkus.container-image.build=true \
    clean package
else
    if [ $dockerHubType = "true" ]
    then
    ./mvnw \
    -Dquarkus.container-image.group=$dockerGroup \
    -Dquarkus.container-image.name=$imageNameAccount \
    -Dquarkus.container-image.tag=$versionAccount \
    -Dquarkus.container-image.additional-tags=latest \
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

#### hcms
#### Cricket HCMS should be build in its own project
#if [ -z "$2" ] || [ "$2" = "cricket-hcms" ]; then
#cd ../cricket-hcms
#./mvnw versions:set -DnewVersion=$versionHcms
#retVal=$?
#if [ $retVal -ne 0 ]; then
#    exit $retval
#fi
#if [ -z "$dockerRegistry" ]
#then
#    echo
#    ./mvnw \
#    -Dquarkus.container-image.name=$imageNameHcms \
#    -Dquarkus.container-image.tag=$versionHcms \
#    -Dquarkus.container-image.additional-tags=latest \
#    -Dquarkus.container-image.build=true \
#    clean package
#else
#    if [ $dockerHubType = "true" ]
#    then
#    ./mvnw \
#    -Dquarkus.container-image.group=$dockerGroup \
#    -Dquarkus.container-image.name=$imageNameHcms \
#    -Dquarkus.container-image.tag=$versionHcms \
#    -Dquarkus.container-image.additional-tags=latest \
#    -Dquarkus.container-image.push=true \
#    clean package
#    else
#    ./mvnw \
#    -Dquarkus.container-image.registry=$dockerRegistry \
#    -Dquarkus.container-image.group=$dockerGroup \
#    -Dquarkus.container-image.username=$dockerUser \
#    -Dquarkus.container-image.password=$dockerPassword \
#    -Dquarkus.container-image.name=$imageNameHcms \
#    -Dquarkus.container-image.tag=$versionHcms \
#    -Dquarkus.container-image.additional-tags=latest \
#    -Dquarkus.container-image.push=true \
#    clean package
#    fi
#fi
#retVal=$?
#if [ $retVal -ne 0 ]; then
#    exit $retval
#fi
#echo
#fi

### signomix-webapp
if [ -z "$2" ] || [ "$2" = "signomix-webapp" ]; then
cd ../signomix-webapp
if [ -z "$dockerRegistry" ]
then
    docker build -t $imageNameWebapp:$versionWebapp -t $imageNameWebapp:latest .
else
    if [ $dockerHubType = "true" ]
    then
    docker build -t $dockerUser/$imageNameWebapp:$versionWebapp -t $dockerUser/$imageNameWebapp:latest .
    docker push $dockerUser/$imageNameWebapp:$versionWebapp
    docker push $dockerUser/$imageNameWebapp:latest
    else
    docker build -t $dockerRegistry/$dockerGroup/$imageNameWebapp:$versionWebapp -t $dockerRegistry/$dockerGroup/$imageNameWebapp:latest .
    docker push $dockerRegistry/$dockerGroup/$imageNameWebapp:$versionWebapp
    docker push $dockerRegistry/$dockerGroup/$imageNameWebapp:latest
    fi
fi
retVal=$?
if [ $retVal -ne 0 ]; then
    exit $retval
fi
echo
fi

### signomix-docs-website
if [ -z "$2" ] || [ "$2" = "signomix-docs-website" ]; then
cd ../signomix-docs-website
echo "PUBLIC_HCMS_URL = 'http://hcms:8080/api/docs'" > .env
echo "PUBLIC_HCMS_INDEX = 'index.md'" >> .env
echo "PUBLIC_HCMS_ROOT = 'signomix'" >> .env
if [ -z "$dockerRegistry" ]
then
    docker build -t $imageNameDocsWebsite:$versionDocsWebsite -t $imageNameDocsWebsite:latest .
else
    if [ $dockerHubType = "true" ]
    then
    docker build -t $dockerUser/$imageNameDocsWebsite:$versionDocsWebsite -t $dockerUser/$imageNameDocsWebsite:latest .
    docker push $dockerUser/$imageNameDocsWebsite:$versionDocsWebsite
    docker push $dockerUser/$imageNameDocsWebsite:latest
    else
    docker build -t $dockerRegistry/$dockerGroup/$imageNameDocsWebsite:$versionDocsWebsite -t $dockerRegistry/$dockerGroup/$imageNameDocsWebsite:latest .
    docker push $dockerRegistry/$dockerGroup/$imageNameDocsWebsite:$versionDocsWebsite
    docker push $dockerRegistry/$dockerGroup/$imageNameDocsWebsite:latest
    fi
fi
retVal=$?
if [ $retVal -ne 0 ]; then
    exit $retval
fi
echo
fi

### signomix-view
if [ -z "$2" ] || [ "$2" = "signomix-view" ]; then
cd ../signomix-view
if [ -z "$dockerRegistry" ]
then
    docker build -t $imageNameView:$versionView -t $imageNameView:latest .
else
    if [ $dockerHubType = "true" ]
    then
    docker build -t $dockerUser/$imageNameView:$versionView -t $dockerUser/$imageNameView:latest .
    docker push $dockerUser/$imageNameView:$versionView
    docker push $dockerUser/$imageNameView:latest
    else
    docker build -t $dockerRegistry/$dockerGroup/$imageNameView:$versionView -t $dockerRegistry/$dockerGroup/$imageNameView:latest .
    docker push $dockerRegistry/$dockerGroup/$imageNameView:$versionView
    docker push $dockerRegistry/$dockerGroup/$imageNameView:latest
    fi
fi
retVal=$?
if [ $retVal -ne 0 ]; then
    exit $retval
fi
echo
fi

### signomix-sentinel
if [ -z "$2" ] || [ "$2" = "signomix-sentinel" ]; then
cd ../signomix-sentinel
./mvnw versions:set -DnewVersion=$versionSentinel
retVal=$?
if [ $retVal -ne 0 ]; then
    exit $retval
fi
if [ -z "$dockerRegistry" ]
then
    echo
    ./mvnw \
    -Dquarkus.container-image.name=$imageNameSentinel \
    -Dquarkus.container-image.tag=$versionSentinel \
    -Dquarkus.container-image.additional-tags=latest \
    -Dquarkus.container-image.build=true \
    clean package
else
    if [ $dockerHubType = "true" ]
    then
    ./mvnw \
    -Dquarkus.container-image.group=$dockerGroup \
    -Dquarkus.container-image.name=$imageNameSentinel \
    -Dquarkus.container-image.tag=$versionSentinel \
    -Dquarkus.container-image.additional-tags=latest \
    -Dquarkus.container-image.push=true \
    clean package
    else
    ./mvnw \
    -Dquarkus.container-image.registry=$dockerRegistry \
    -Dquarkus.container-image.group=$dockerGroup \
    -Dquarkus.container-image.username=$dockerUser \
    -Dquarkus.container-image.password=$dockerPassword \
    -Dquarkus.container-image.name=$imageNameSentinel \
    -Dquarkus.container-image.tag=$versionSentinel \
    -Dquarkus.container-image.additional-tags=latest \
    -Dquarkus.container-image.push=true \
    clean package
    fi
fi
retVal=$?
if [ $retVal -ne 0 ]; then
    exit $retval
fi
fi

### signomix-reports
if [ -z "$2" ] || [ "$2" = "signomix-reports" ]; then
cd ../signomix-reports
./mvnw versions:set -DnewVersion=$versionReports
retVal=$?
if [ $retVal -ne 0 ]; then
    exit $retval
fi
if [ -z "$dockerRegistry" ]
then
    echo
    ./mvnw \
    -Dquarkus.container-image.name=$imageNameReports \
    -Dquarkus.container-image.tag=$versionReports \
    -Dquarkus.container-image.additional-tags=latest \
    -Dquarkus.container-image.build=true \
    clean package
else
    if [ $dockerHubType = "true" ]
    then
    ./mvnw \
    -Dquarkus.container-image.group=$dockerGroup \
    -Dquarkus.container-image.name=$imageNameReports \
    -Dquarkus.container-image.tag=$versionReports \
    -Dquarkus.container-image.additional-tags=latest \
    -Dquarkus.container-image.push=true \
    clean package
    else
    ./mvnw \
    -Dquarkus.container-image.registry=$dockerRegistry \
    -Dquarkus.container-image.group=$dockerGroup \
    -Dquarkus.container-image.username=$dockerUser \
    -Dquarkus.container-image.password=$dockerPassword \
    -Dquarkus.container-image.name=$imageNameReports \
    -Dquarkus.container-image.tag=$versionReports \
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

### signomix-lb but only if signomix-proxy2 exists
if [ -z "$2" ] || [ "$2" = "signomix-lb" ]; then
if [ -d "../signomix-proxy2" ]; then
cd ../signomix-proxy2
if [ -z "$dockerRegistry" ]
then
    docker build --build-arg DOMAIN=$signomixDomain -t $imageNameLb:$versionLb -t $imageNameLb:latest .
else
    if [ $dockerHubType = "true" ]
    then
    docker build --build-arg DOMAIN=$signomixDomain -t $dockerUser/$imageNameLb:$versionLb -t $dockerUser/$imageNameLb:latest .
    docker push $dockerUser/$imageNameLb:$versionLb
    docker push $dockerUser/$imageNameLb:latest
    else
    docker build --build-arg DOMAIN=$signomixDomain -t $dockerRegistry/$dockerGroup/$imageNameLb:$versionLb -t $dockerRegistry/$dockerGroup/$imageNameLb:latest .
    docker push $dockerRegistry/$dockerGroup/$imageNameLb:$versionLb
    docker push $dockerRegistry/$dockerGroup/$imageNameLb:latest
    fi
fi
retVal=$?
if [ $retVal -ne 0 ]; then
    exit $retval
fi
echo
fi
fi

### signomix-website but only if signomix-website exists
if [ -z "$2" ] || [ "$2" = "signomix-website" ]; then
if [ -d "../signomix-website" ]; then
cd ../signomix-website
echo "PUBLIC_HCMS_URL = 'http://website-hcms:8080/api/docs'" > .env
echo "PUBLIC_HCMS_INDEX = 'pl/index.html'" >> .env
echo "PUBLIC_HCMS_ROOT = 'home'" >> .env
if [ -z "$dockerRegistry" ]
then
    docker build -t $imageNameWebsite:$versionWebsite -t $imageNameWebsite:latest .
else
    if [ $dockerHubType = "true" ]
    then
    docker build -t $dockerUser/$imageNameWebsite:$versionWebsite -t $dockerUser/$imageNameWebsite:latest .
    docker push $dockerUser/$imageNameWebsite:$versionWebsite
    docker push $dockerUser/$imageNameWebsite:latest
    else
    docker build -t $dockerRegistry/$dockerGroup/$imageNameWebsite:$versionWebsite -t $dockerRegistry/$dockerGroup/$imageNameWebsite:latest .
    docker push $dockerRegistry/$dockerGroup/$imageNameWebsite:$versionWebsite
    docker push $dockerRegistry/$dockerGroup/$imageNameWebsite:latest
    fi
fi
retVal=$?
if [ $retVal -ne 0 ]; then
    exit $retval
fi
echo
fi
fi

### saving images
cd ../signomix
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
    docker save $imageNameMs:$versionMs | gzip > local-images/$imageNameMs.tar.gz
    docker save $imageNameLb:$versionLb | gzip > local-images/$imageNameLb.tar.gz
    docker save $imageNameGateway:$versionGateway | gzip > local-images/$imageNameGateway.tar.gz
    docker save $imageNameReceiver:$versionReceiver | gzip > local-images/$imageNameReceiver.tar.gz
    docker save $imageNameProvider:$versionProvider | gzip > local-images/$imageNameProvider.tar.gz
    docker save $imageNameCore:$versionCore | gzip > local-images/$imageNameCore.tar.gz
    docker save $imageNameJobs:$versionJobs | gzip > local-images/$imageNameJobs.tar.gz
    docker save $imageNameAuth:$versionAuth | gzip > local-images/$imageNameAuth.tar.gz
    docker save $imageNameDocsWebsite:$versionDocsWebsite | gzip > local-images/$imageNameDocsWebsite.tar.gz
    docker save $imageNameView:$versionView | gzip > local-images/$imageNameView.tar.gz
    docker save $imageNameSentinel:$versionSentinel | gzip > local-images/$imageNameSentinel.tar.gz
    docker save $imageNameReports:$versionReports | gzip > local-images/$imageNameReports.tar.gz
    echo "saved"
    fi
fi
# done

