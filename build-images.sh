#!/bin/bash

# Script to build Signomix images

################################
## CONFIGURATION
##

# versions
SGX_APP_VERSION=1.0.4
SGX_ACCOUNT_VERSION=1.0.4
SGX_AUTH_VERSION=1.0.0
SGX_COMMON_VERSION=1.0.0
SGX_MS_VERSION=1.0.3
SGX_PROVIDER_VERSION=0.0.1
SGX_LB_VERSION=1.0.0
SGX_GATEWAY_VERSION=1.0.0
SGX_RECEIVER_VERSION=1.0.0
SGX_CORE_VERSION=1.0.0
SGX_JOBS_VERSION=1.0.0
SGX_DOCS_VERSION=1.0.0
SGX_VIEW_VERSION=1.0.0
SGX_WEBAPP_VERSION=1.0.0
SGX_SENTINEL_VERSION=1.0.0
SGX_HCMS_VERSION=1.0.0
SGX_WEBSITE_VERSION=1.0.0
SGX_REPORTS_VERSION=1.0.0
#orderformUrlPl=https://orderform.mydomain.com/pl
#orderformUrlEn=https://orderform.mydomain.com/en

# names
SGX_APP_NAME=signomix-ta-app
SGX_ACCOUNT_NAME=signomix-ta-account
SGX_AUTH_NAME=signomix-auth
SGX_MS_NAME=signomix-ta-ms
SGX_PROVIDER_NAME=signomix-ta-provider
SGX_GATEWAY_NAME=signomix-gateway
SGX_LB_NAME=signomix-lb
SGX_RECEIVER_NAME=signomix-ta-receiver
SGX_CORE_NAME=signomix-ta-core
SGX_JOBS_NAME=signomix-ta-jobs
SGX_DOCS_NAME=signomix-docs-website
SGX_HCMS_NAME=cricket-hcms
SGX_VIEW_NAME=signomix-view
SGX_SENTINEL_NAME=signomix-sentinel
SGX_WEBAPP_NAME=signomix-webapp
SGX_WEBSITE_NAME=signomix-website
SGX_REPORTS_NAME=signomix-reports
SGX_COMMON_NAME=signomix-common

# decide if common lib should be built
build_common_lib=no
java_services="$SGX_ACCOUNT_NAME $SGX_APP_NAME $SGX_AUTH_NAME $SGX_CORE_NAME $SGX_MS_NAME $SGX_JOBS_NAME"
java_services="$java_services $SGX_PROVIDER_NAME $SGX_RECEIVER_NAME $SGX_REPORTS_NAME $SGX_SENTINEL_NAME"
for i in $java_services
do
    echo "$i"
    if [ "$2" = "$i" ]; then
        build_common_lib=yes
    fi
done 

## proxy config
# domain [mydomain.com | localhost ]
SGX_DOMAIN=mydomain.com
SGX_STATUS_PAGE=https://status.mydomain.com
#dbpassword=signomixdbpwd

# repository
SGX_DOCKER_REGISTRY=
SGX_DOCKERHUB_TYPE=true
SGX_EXPORT_IMAGES=true

# other
SGX_DEFAULT_ORGANIZATION_ID=0


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

# print config
echo
echo "SGX_APP_VERSION=$SGX_APP_VERSION"
echo "SGX_ACCOUNT_VERSION=$SGX_ACCOUNT_VERSION"
echo "SGX_AUTH_VERSION=$SGX_AUTH_VERSION"
echo "SGX_COMMON_VERSION=$SGX_COMMON_VERSION"
cat ../signomix-common/pom.xml|grep versionCommon
echo "SGX_MS_VERSION=$SGX_MS_VERSION"
echo "SGX_PROVIDER_VERSION=$SGX_PROVIDER_VERSION"
echo "SGX_RECEIVER_VERSION=$SGX_RECEIVER_VERSION"
echo "SGX_CORE_VERSION=$SGX_CORE_VERSION"
echo "SGX_JOBS_VERSION=$SGX_JOBS_VERSION"
echo "SGX_DOCS_VERSION=$SGX_DOCS_VERSION"
echo "SGX_HCMS_VERSION=$SGX_HCMS_VERSION"
echo "SGX_VIEW_VERSION=$SGX_VIEW_VERSION"
echo "SGX_SENTINEL_VERSION=$SGX_SENTINEL_VERSION"
echo "SGX_WEBAPP_VERSION=$SGX_WEBAPP_VERSION"
echo "SGX_WEBSITE_VERSION=$SGX_WEBSITE_VERSION"
echo "SGX_REPORTS_VERSION=$SGX_REPORTS_VERSION"

echo
echo "SGX_APP_NAME=$SGX_APP_NAME"
echo "SGX_ACCOUNT_NAME=$SGX_ACCOUNT_NAME"
echo "SGX_AUTH_NAME=$SGX_AUTH_NAME"
echo "SGX_MS_NAME=$SGX_MS_NAME"
echo "SGX_PROVIDER_NAME=$SGX_PROVIDER_NAME"
echo "imageNameProxy2=$imageNameProxy2"
echo "SGX_RECEIVER_NAME=$SGX_RECEIVER_NAME"
echo "SGX_CORE_NAME=$SGX_CORE_NAME"
echo "SGX_JOBS_NAME=$SGX_JOBS_NAME"
echo "SGX_DOCS_NAME=$SGX_DOCS_NAME"
echo "SGX_HCMS_NAME=$SGX_HCMS_NAME"
echo "SGX_VIEW_NAME=$SGX_VIEW_NAME"
echo "SGX_SENTINEL_NAME=$SGX_SENTINEL_NAME"
echo "SGX_WEBAPP_NAME=$SGX_WEBAPP_NAME"
echo "SGX_WEBSITE_NAME=$SGX_WEBSITE_NAME"
echo "SGX_REPORTS_NAME=$SGX_REPORTS_NAME"
echo
echo "SGX_DOMAIN=$SGX_DOMAIN"
echo "SGX_STATUS_PAGE=$SGX_STATUS_PAGE"
echo "SGX_DOCKERHUB_TYPE=$SGX_DOCKERHUB_TYPE"
echo "SGX_DOCKER_REGISTRY=$SGX_DOCKER_REGISTRY"
echo "SGX_DOCKER_GROUP=$SGX_DOCKER_GROUP"
echo "SGX_DOCKER_USER=$SGX_DOCKER_USER"
echo "SGX_DOCKER_PASSWORD=$SGX_DOCKER_PASSWORD"
#echo "withGraylog=$withGraylog"
echo "SGX_EXPORT_IMAGES=$SGX_EXPORT_IMAGES"
#echo "orderformUrlPl=$orderformUrlPl"
#echo "orderformUrlEn=$orderformUrlEn"
echo "SIGNOMIX_TITLE=$SGX_TITLE"
echo "SGX_DEFAULT_ORGANIZATION_ID=$SGX_DEFAULT_ORGANIZATION_ID"
echo "RELEASE VERSION=$SGX_RELEASE_VERSION"
echo "RELEASE REPO NAME=$SGX_RELEASE_REPO_NAME"
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

# Clear the build-report.txt file
> ../signomix/build-report.txt
echo "#$(date --iso-8601=minutes -u)" >> ../signomix/build-report.txt

### signomix-apigateway
if [ -z "$2" ] || [ "$2" = "signomix-gateway" ] || [ "$2" = "signomix-apigateway" ]; then
cd ../signomix-apigateway
if [ -z "$SGX_DOCKER_REGISTRY" ]
then
    docker build --build-arg DOMAIN=$SGX_DOMAIN -t $SGX_GATEWAY_NAME:$SGX_GATEWAY_VERSION -t $SGX_GATEWAY_NAME:latest .
else
    if [ $SGX_DOCKERHUB_TYPE = "true" ]
    then
    docker build --build-arg DOMAIN=$SGX_DOMAIN -t $SGX_DOCKER_USER/$SGX_GATEWAY_NAME:$SGX_GATEWAY_VERSION -t $SGX_DOCKER_USER/$SGX_GATEWAY_NAME:latest .
    docker push $SGX_DOCKER_USER/$SGX_GATEWAY_NAME:$SGX_GATEWAY_VERSION
    docker push $SGX_DOCKER_USER/$SGX_GATEWAY_NAME:latest
    else
    docker build --build-arg DOMAIN=$SGX_DOMAIN -t $SGX_DOCKER_REGISTRY/$SGX_DOCKER_GROUP/$SGX_GATEWAY_NAME:$SGX_GATEWAY_VERSION -t $SGX_DOCKER_REGISTRY/$SGX_DOCKER_GROUP/$SGX_GATEWAY_NAME:latest .
    docker push $SGX_DOCKER_REGISTRY/$SGX_DOCKER_GROUP/$SGX_GATEWAY_NAME:$SGX_GATEWAY_VERSION
    docker push $SGX_DOCKER_REGISTRY/$SGX_DOCKER_GROUP/$SGX_GATEWAY_NAME:latest
    fi
fi
retVal=$?
if [ $retVal -ne 0 ]; then
    exit $retval
fi
echo $SGX_GATEWAY_NAME:$SGX_GATEWAY_VERSION >> ../signomix/build-report.txt
echo
fi

### signomix-common
if [ -z "$2" ] || [ "$build_common_lib" = "yes" ]; 
then
cd ../signomix-common
mvn versions:set -DnewVersion=$SGX_COMMON_VERSION
mvn clean install
retVal=$?
if [ $retVal -ne 0 ]; then
    exit $retval
fi
echo $SGX_COMMON_NAME:$SGX_COMMON_VERSION >> ../signomix/build-report.txt
fi

### signomix-jobs
if [ -z "$2" ] || [ "$2" = "signomix-ta-jobs" ]; then
cd ../signomix-ta-jobs
./mvnw versions:set -DnewVersion=$SGX_JOBS_VERSION
retVal=$?
if [ $retVal -ne 0 ]; then
    exit $retval
fi
if [ -z "$SGX_DOCKER_REGISTRY" ]
then
    echo
    ./mvnw \
    -Dquarkus.container-image.name=$SGX_JOBS_NAME \
    -Dquarkus.container-image.tag=$SGX_JOBS_VERSION \
    -Dquarkus.container-image.additional-tags=latest \
    -Dquarkus.container-image.build=true \
    clean package
else
    if [ $SGX_DOCKERHUB_TYPE = "true" ]
    then
    ./mvnw \
    -Dquarkus.container-image.group=$SGX_DOCKER_GROUP \
    -Dquarkus.container-image.name=$SGX_JOBS_NAME \
    -Dquarkus.container-image.tag=$SGX_JOBS_VERSION \
    -Dquarkus.container-image.additional-tags=latest \
    -Dquarkus.container-image.push=true \
    clean package
    else
        ./mvnw \
    -Dquarkus.container-image.registry=$SGX_DOCKER_REGISTRY \
    -Dquarkus.container-image.group=$SGX_DOCKER_GROUP \
    -Dquarkus.container-image.username=$SGX_DOCKER_USER \
    -Dquarkus.container-image.password=$SGX_DOCKER_PASSWORD \
    -Dquarkus.container-image.name=$SGX_JOBS_NAME \
    -Dquarkus.container-image.tag=$SGX_JOBS_VERSION \
    -Dquarkus.container-image.additional-tags=latest \
    -Dquarkus.container-image.push=true \
    clean package
    fi
fi
retVal=$?
if [ $retVal -ne 0 ]; then
    exit $retval
fi
echo $SGX_JOBS_NAME:$SGX_JOBS_VERSION >> ../signomix/build-report.txt
fi

### signomix-core
if [ -z "$2" ] || [ "$2" = "signomix-ta-core" ]; then
cd ../signomix-ta-core
./mvnw versions:set -DnewVersion=$SGX_CORE_VERSION
retVal=$?
if [ $retVal -ne 0 ]; then
    exit $retval
fi
if [ -z "$SGX_DOCKER_REGISTRY" ]
then
    echo
    ./mvnw \
    -Dquarkus.container-image.name=$SGX_CORE_NAME \
    -Dquarkus.container-image.tag=$SGX_CORE_VERSION \
    -Dquarkus.container-image.additional-tags=latest \
    -Dquarkus.container-image.build=true \
    clean package
else
    if [ $SGX_DOCKERHUB_TYPE = "true" ]
    then
    ./mvnw \
    -Dquarkus.container-image.group=$SGX_DOCKER_GROUP \
    -Dquarkus.container-image.name=$SGX_CORE_NAME \
    -Dquarkus.container-image.tag=$SGX_CORE_VERSION \
    -Dquarkus.container-image.additional-tags=latest \
    -Dquarkus.container-image.push=true \
    clean package
    else
    ./mvnw \
    -Dquarkus.container-image.registry=$SGX_DOCKER_REGISTRY \
    -Dquarkus.container-image.group=$SGX_DOCKER_GROUP \
    -Dquarkus.container-image.username=$SGX_DOCKER_USER \
    -Dquarkus.container-image.password=$SGX_DOCKER_PASSWORD \
    -Dquarkus.container-image.name=$SGX_CORE_NAME \
    -Dquarkus.container-image.tag=$SGX_CORE_VERSION \
    -Dquarkus.container-image.additional-tags=latest \
    -Dquarkus.container-image.push=true \
    clean package
    fi
fi
retVal=$?
if [ $retVal -ne 0 ]; then
    exit $retval
fi
echo $SGX_CORE_NAME:$SGX_CORE_VERSION >> ../signomix/build-report.txt
fi

### signomix-auth
if [ -z "$2" ] || [ "$2" = "signomix-auth" ]; then
cd ../signomix-auth
./mvnw versions:set -DnewVersion=$SGX_AUTH_VERSION
retVal=$?
if [ $retVal -ne 0 ]; then
    exit $retval
fi
if [ -z "$SGX_DOCKER_REGISTRY" ]
then
    echo
    ./mvnw \
    -Dquarkus.container-image.name=$SGX_AUTH_NAME \
    -Dquarkus.container-image.tag=$SGX_AUTH_VERSION \
    -Dquarkus.container-image.additional-tags=latest \
    -Dquarkus.container-image.build=true \
    clean package
else
    if [ $SGX_DOCKERHUB_TYPE = "true" ]
    then
    ./mvnw \
    -Dquarkus.container-image.group=$SGX_DOCKER_GROUP \
    -Dquarkus.container-image.name=$SGX_AUTH_NAME \
    -Dquarkus.container-image.tag=$SGX_AUTH_VERSION \
    -Dquarkus.container-image.additional-tags=latest \
    -Dquarkus.container-image.push=true \
    clean package
    else
    ./mvnw \
    -Dquarkus.container-image.registry=$SGX_DOCKER_REGISTRY \
    -Dquarkus.container-image.group=$SGX_DOCKER_GROUP \
    -Dquarkus.container-image.username=$SGX_DOCKER_USER \
    -Dquarkus.container-image.password=$SGX_DOCKER_PASSWORD \
    -Dquarkus.container-image.name=$SGX_AUTH_NAME \
    -Dquarkus.container-image.tag=$SGX_AUTH_VERSION \
    -Dquarkus.container-image.additional-tags=latest \
    -Dquarkus.container-image.push=true \
    clean package
    fi
fi
retVal=$?
if [ $retVal -ne 0 ]; then
    exit $retval
fi
echo $SGX_AUTH_NAME:$SGX_AUTH_VERSION >> ../signomix/build-report.txt
fi

### signomix-ta-app
if [ -z "$2" ] || [ "$2" = "signomix-ta-app" ]; then
cd ../signomix-ta-app
./mvnw versions:set -DnewVersion=$SGX_APP_VERSION
retVal=$?
if [ $retVal -ne 0 ]; then
    exit $retval
fi
if [ -z "$SGX_DOCKER_REGISTRY" ]
then
    echo
    ./mvnw \
    -DSIGNOMIX_IMAGE_NAME=$SGX_APP_NAME \
    -DSIGNOMIX_IMAGE_TAG=$SGX_APP_VERSION \
    -Dquarkus.container-image.name=$SGX_APP_NAME \
    -Dquarkus.container-image.tag=$SGX_APP_VERSION \
    -Dquarkus.container-image.additional-tags=latest \
    -Dquarkus.container-image.build=true \
    clean package
else
    if [ $SGX_DOCKERHUB_TYPE = "true" ]
    then
    ./mvnw \
    -DSIGNOMIX_IMAGE_NAME=$SGX_APP_NAME \
    -DSIGNOMIX_IMAGE_TAG=$SGX_APP_VERSION \
    -Dquarkus.container-image.group=$SGX_DOCKER_GROUP \
    -Dquarkus.container-image.name=$SGX_APP_NAME \
    -Dquarkus.container-image.tag=$SGX_APP_VERSION \
    -Dquarkus.container-image.additional-tags=latest \
    -Dquarkus.container-image.push=true \
    clean package
    else
    ./mvnw \
    -DSIGNOMIX_IMAGE_NAME=$SGX_APP_NAME \
    -DSIGNOMIX_IMAGE_TAG=$SGX_APP_VERSION \
    -Dquarkus.container-image.registry=$SGX_DOCKER_REGISTRY \
    -Dquarkus.container-image.group=$SGX_DOCKER_GROUP \
    -Dquarkus.container-image.username=$SGX_DOCKER_USER \
    -Dquarkus.container-image.password=$SGX_DOCKER_PASSWORD \
    -Dquarkus.container-image.name=$SGX_APP_NAME \
    -Dquarkus.container-image.tag=$SGX_APP_VERSION \
    -Dquarkus.container-image.additional-tags=latest \
    -Dquarkus.container-image.push=true \
    clean package
    fi
fi
retVal=$?
if [ $retVal -ne 0 ]; then
    exit $retval
fi
echo $SGX_APP_NAME:$SGX_APP_VERSION >> ../signomix/build-report.txt
echo
fi

### signomix-ta-ms
if [ -z "$2" ] || [ "$2" = "signomix-ta-ms" ]; then
cd ../signomix-ta-ms
./mvnw versions:set -DnewVersion=$SGX_MS_VERSION
retVal=$?
if [ $retVal -ne 0 ]; then
    exit $retval
fi
if [ -z "$SGX_DOCKER_REGISTRY" ]
then
    echo
    ./mvnw \
    -Dquarkus.container-image.name=$SGX_MS_NAME \
    -Dquarkus.container-image.tag=$SGX_MS_VERSION \
    -Dquarkus.container-image.additional-tags=latest \
    -Dquarkus.container-image.build=true \
    clean package
else
    if [ $SGX_DOCKERHUB_TYPE = "true" ]
    then
    ./mvnw \
    -Dquarkus.container-image.group=$SGX_DOCKER_GROUP \
    -Dquarkus.container-image.name=$SGX_MS_NAME \
    -Dquarkus.container-image.tag=$SGX_MS_VERSION \
    -Dquarkus.container-image.additional-tags=latest \
    -Dquarkus.container-image.push=true \
    clean package
    else
    ./mvnw \
    -Dquarkus.container-image.registry=$SGX_DOCKER_REGISTRY \
    -Dquarkus.container-image.group=$SGX_DOCKER_GROUP \
    -Dquarkus.container-image.username=$SGX_DOCKER_USER \
    -Dquarkus.container-image.password=$SGX_DOCKER_PASSWORD \
    -Dquarkus.container-image.name=$SGX_MS_NAME \
    -Dquarkus.container-image.tag=$SGX_MS_VERSION \
    -Dquarkus.container-image.additional-tags=latest \
    -Dquarkus.container-image.push=true \
    clean package
    fi
fi
retVal=$?
if [ $retVal -ne 0 ]; then
    exit $retval
fi
echo $SGX_MS_NAME:$SGX_MS_VERSION >> ../signomix/build-report.txt
echo
fi

### signomix-ta-receiver
if [ -z "$2" ] || [ "$2" = "signomix-ta-receiver" ]; then
cd ../signomix-ta-receiver
./mvnw versions:set -DnewVersion=$SGX_RECEIVER_VERSION
retVal=$?
if [ $retVal -ne 0 ]; then
    exit $retval
fi
if [ -z "$SGX_DOCKER_REGISTRY" ]
then
    echo
    ./mvnw \
    -Dquarkus.container-image.name=$SGX_RECEIVER_NAME \
    -Dquarkus.container-image.tag=$SGX_RECEIVER_VERSION \
    -Dquarkus.container-image.additional-tags=latest \
    -Dquarkus.container-image.build=true \
    clean package
else
    if [ $SGX_DOCKERHUB_TYPE = "true" ]
    then
    ./mvnw \
    -Dquarkus.container-image.group=$SGX_DOCKER_GROUP \
    -Dquarkus.container-image.name=$SGX_RECEIVER_NAME \
    -Dquarkus.container-image.tag=$SGX_RECEIVER_VERSION \
    -Dquarkus.container-image.additional-tags=latest \
    -Dquarkus.container-image.push=true \
    clean package
    else
    ./mvnw \
    -Dquarkus.container-image.registry=$SGX_DOCKER_REGISTRY \
    -Dquarkus.container-image.group=$SGX_DOCKER_GROUP \
    -Dquarkus.container-image.username=$SGX_DOCKER_USER \
    -Dquarkus.container-image.password=$SGX_DOCKER_PASSWORD \
    -Dquarkus.container-image.name=$SGX_RECEIVER_NAME \
    -Dquarkus.container-image.tag=$SGX_RECEIVER_VERSION \
    -Dquarkus.container-image.additional-tags=latest \
    -Dquarkus.container-image.push=true \
    clean package
    fi
fi
retVal=$?
if [ $retVal -ne 0 ]; then
    exit $retval
fi
echo $SGX_RECEIVER_NAME:$SGX_RECEIVER_VERSION >> ../signomix/build-report.txt
echo
fi

### signomix-ta-provider
if [ -z "$2" ] || [ "$2" = "signomix-ta-provider" ]; then
cd ../signomix-ta-provider
./mvnw versions:set -DnewVersion=$SGX_PROVIDER_VERSION
retVal=$?
if [ $retVal -ne 0 ]; then
    exit $retval
fi
if [ -z "$SGX_DOCKER_REGISTRY" ]
then
    echo
    ./mvnw \
    -Dquarkus.container-image.name=$SGX_PROVIDER_NAME \
    -Dquarkus.container-image.tag=$SGX_PROVIDER_VERSION \
    -Dquarkus.container-image.additional-tags=latest \
    -Dquarkus.container-image.build=true \
    clean package
else
    if [ $SGX_DOCKERHUB_TYPE = "true" ]
    then
    ./mvnw \
    -Dquarkus.container-image.group=$SGX_DOCKER_GROUP \
    -Dquarkus.container-image.name=$SGX_PROVIDER_NAME \
    -Dquarkus.container-image.tag=$SGX_PROVIDER_VERSION \
    -Dquarkus.container-image.additional-tags=latest \
    -Dquarkus.container-image.push=true \
    clean package
    else
    ./mvnw \
    -Dquarkus.container-image.registry=$SGX_DOCKER_REGISTRY \
    -Dquarkus.container-image.group=$SGX_DOCKER_GROUP \
    -Dquarkus.container-image.username=$SGX_DOCKER_USER \
    -Dquarkus.container-image.password=$SGX_DOCKER_PASSWORD \
    -Dquarkus.container-image.name=$SGX_PROVIDER_NAME \
    -Dquarkus.container-image.tag=$SGX_PROVIDER_VERSION \
    -Dquarkus.container-image.additional-tags=latest \
    -Dquarkus.container-image.push=true \
    clean package
    fi
fi
retVal=$?
if [ $retVal -ne 0 ]; then
    exit $retval
fi
echo $SGX_PROVIDER_NAME:$SGX_PROVIDER_VERSION >> ../signomix/build-report.txt
echo
fi

### signomix-ta-account
if [ -z "$2" ] || [ "$2" = "signomix-ta-account" ]; then
cd ../signomix-ta-account
./mvnw versions:set -DnewVersion=$SGX_ACCOUNT_VERSION
retVal=$?
if [ $retVal -ne 0 ]; then
    exit $retval
fi
if [ -z "$SGX_DOCKER_REGISTRY" ]
then
    echo
    ./mvnw \
    -Dquarkus.container-image.name=$SGX_ACCOUNT_NAME \
    -Dquarkus.container-image.tag=$SGX_ACCOUNT_VERSION \
    -Dquarkus.container-image.additional-tags=latest \
    -Dquarkus.container-image.build=true \
    clean package
else
    if [ $SGX_DOCKERHUB_TYPE = "true" ]
    then
    ./mvnw \
    -Dquarkus.container-image.group=$SGX_DOCKER_GROUP \
    -Dquarkus.container-image.name=$SGX_ACCOUNT_NAME \
    -Dquarkus.container-image.tag=$SGX_ACCOUNT_VERSION \
    -Dquarkus.container-image.additional-tags=latest \
    -Dquarkus.container-image.push=true \
    clean package
    else
    ./mvnw \
    -Dquarkus.container-image.registry=$SGX_DOCKER_REGISTRY \
    -Dquarkus.container-image.group=$SGX_DOCKER_GROUP \
    -Dquarkus.container-image.username=$SGX_DOCKER_USER \
    -Dquarkus.container-image.password=$SGX_DOCKER_PASSWORD \
    -Dquarkus.container-image.name=$SGX_ACCOUNT_NAME \
    -Dquarkus.container-image.tag=$SGX_ACCOUNT_VERSION \
    -Dquarkus.container-image.additional-tags=latest \
    -Dquarkus.container-image.push=true \
    clean package
    fi
fi
retVal=$?
if [ $retVal -ne 0 ]; then
    exit $retval
fi
echo $SGX_ACCOUNT_NAME:$SGX_ACCOUNT_VERSION >> ../signomix/build-report.txt
echo
fi

#### hcms
#### Cricket HCMS should be build in its own project
#if [ -z "$2" ] || [ "$2" = "cricket-hcms" ]; then
#cd ../cricket-hcms
#./mvnw versions:set -DnewVersion=$SGX_HCMS_VERSION
#retVal=$?
#if [ $retVal -ne 0 ]; then
#    exit $retval
#fi
#if [ -z "$SGX_DOCKER_REGISTRY" ]
#then
#    echo
#    ./mvnw \
#    -Dquarkus.container-image.name=$SGX_HCMS_NAME \
#    -Dquarkus.container-image.tag=$SGX_HCMS_VERSION \
#    -Dquarkus.container-image.additional-tags=latest \
#    -Dquarkus.container-image.build=true \
#    clean package
#else
#    if [ $SGX_DOCKERHUB_TYPE = "true" ]
#    then
#    ./mvnw \
#    -Dquarkus.container-image.group=$SGX_DOCKER_GROUP \
#    -Dquarkus.container-image.name=$SGX_HCMS_NAME \
#    -Dquarkus.container-image.tag=$SGX_HCMS_VERSION \
#    -Dquarkus.container-image.additional-tags=latest \
#    -Dquarkus.container-image.push=true \
#    clean package
#    else
#    ./mvnw \
#    -Dquarkus.container-image.registry=$SGX_DOCKER_REGISTRY \
#    -Dquarkus.container-image.group=$SGX_DOCKER_GROUP \
#    -Dquarkus.container-image.username=$SGX_DOCKER_USER \
#    -Dquarkus.container-image.password=$SGX_DOCKER_PASSWORD \
#    -Dquarkus.container-image.name=$SGX_HCMS_NAME \
#    -Dquarkus.container-image.tag=$SGX_HCMS_VERSION \
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
if [ -z "$SGX_DOCKER_REGISTRY" ]
then
    docker build -t $SGX_WEBAPP_NAME:$SGX_WEBAPP_VERSION -t $SGX_WEBAPP_NAME:latest .
else
    if [ $SGX_DOCKERHUB_TYPE = "true" ]
    then
    docker build -t $SGX_DOCKER_USER/$SGX_WEBAPP_NAME:$SGX_WEBAPP_VERSION -t $SGX_DOCKER_USER/$SGX_WEBAPP_NAME:latest .
    docker push $SGX_DOCKER_USER/$SGX_WEBAPP_NAME:$SGX_WEBAPP_VERSION
    docker push $SGX_DOCKER_USER/$SGX_WEBAPP_NAME:latest
    else
    docker build -t $SGX_DOCKER_REGISTRY/$SGX_DOCKER_GROUP/$SGX_WEBAPP_NAME:$SGX_WEBAPP_VERSION -t $SGX_DOCKER_REGISTRY/$SGX_DOCKER_GROUP/$SGX_WEBAPP_NAME:latest .
    docker push $SGX_DOCKER_REGISTRY/$SGX_DOCKER_GROUP/$SGX_WEBAPP_NAME:$SGX_WEBAPP_VERSION
    docker push $SGX_DOCKER_REGISTRY/$SGX_DOCKER_GROUP/$SGX_WEBAPP_NAME:latest
    fi
fi
retVal=$?
if [ $retVal -ne 0 ]; then
    exit $retval
fi
echo $SGX_WEBAPP_NAME:$SGX_WEBAPP_VERSION >> ../signomix/build-report.txt
echo
fi

### signomix-docs-website
if [ -z "$2" ] || [ "$2" = "signomix-docs-website" ]; then
cd ../signomix-docs-website
echo "PUBLIC_HCMS_URL = 'http://hcms:8080/api/docs'" > .env
echo "PUBLIC_HCMS_INDEX = 'index.md'" >> .env
echo "PUBLIC_HCMS_ROOT = 'signomix'" >> .env
if [ -z "$SGX_DOCKER_REGISTRY" ]
then
    docker build -t $SGX_DOCS_NAME:$SGX_DOCS_VERSION -t $SGX_DOCS_NAME:latest .
else
    if [ $SGX_DOCKERHUB_TYPE = "true" ]
    then
    docker build -t $SGX_DOCKER_USER/$SGX_DOCS_NAME:$SGX_DOCS_VERSION -t $SGX_DOCKER_USER/$SGX_DOCS_NAME:latest .
    docker push $SGX_DOCKER_USER/$SGX_DOCS_NAME:$SGX_DOCS_VERSION
    docker push $SGX_DOCKER_USER/$SGX_DOCS_NAME:latest
    else
    docker build -t $SGX_DOCKER_REGISTRY/$SGX_DOCKER_GROUP/$SGX_DOCS_NAME:$SGX_DOCS_VERSION -t $SGX_DOCKER_REGISTRY/$SGX_DOCKER_GROUP/$SGX_DOCS_NAME:latest .
    docker push $SGX_DOCKER_REGISTRY/$SGX_DOCKER_GROUP/$SGX_DOCS_NAME:$SGX_DOCS_VERSION
    docker push $SGX_DOCKER_REGISTRY/$SGX_DOCKER_GROUP/$SGX_DOCS_NAME:latest
    fi
fi
retVal=$?
if [ $retVal -ne 0 ]; then
    exit $retval
fi
echo $SGX_DOCS_NAME:$SGX_DOCS_VERSION >> ../signomix/build-report.txt
echo
fi

### signomix-view
if [ -z "$2" ] || [ "$2" = "signomix-view" ]; then
cd ../signomix-view
if [ -z "$SGX_DOCKER_REGISTRY" ]
then
    docker build -t $SGX_VIEW_NAME:$SGX_VIEW_VERSION -t $SGX_VIEW_NAME:latest .
else
    if [ $SGX_DOCKERHUB_TYPE = "true" ]
    then
    docker build -t $SGX_DOCKER_USER/$SGX_VIEW_NAME:$SGX_VIEW_VERSION -t $SGX_DOCKER_USER/$SGX_VIEW_NAME:latest .
    docker push $SGX_DOCKER_USER/$SGX_VIEW_NAME:$SGX_VIEW_VERSION
    docker push $SGX_DOCKER_USER/$SGX_VIEW_NAME:latest
    else
    docker build -t $SGX_DOCKER_REGISTRY/$SGX_DOCKER_GROUP/$SGX_VIEW_NAME:$SGX_VIEW_VERSION -t $SGX_DOCKER_REGISTRY/$SGX_DOCKER_GROUP/$SGX_VIEW_NAME:latest .
    docker push $SGX_DOCKER_REGISTRY/$SGX_DOCKER_GROUP/$SGX_VIEW_NAME:$SGX_VIEW_VERSION
    docker push $SGX_DOCKER_REGISTRY/$SGX_DOCKER_GROUP/$SGX_VIEW_NAME:latest
    fi
fi
retVal=$?
if [ $retVal -ne 0 ]; then
    exit $retval
fi
echo $SGX_VIEW_NAME:$SGX_VIEW_VERSION >> ../signomix/build-report.txt
echo
fi

### signomix-sentinel
if [ -z "$2" ] || [ "$2" = "signomix-sentinel" ]; then
cd ../signomix-sentinel
./mvnw versions:set -DnewVersion=$SGX_SENTINEL_VERSION
retVal=$?
if [ $retVal -ne 0 ]; then
    exit $retval
fi
if [ -z "$SGX_DOCKER_REGISTRY" ]
then
    echo
    ./mvnw \
    -Dquarkus.container-image.name=$SGX_SENTINEL_NAME \
    -Dquarkus.container-image.tag=$SGX_SENTINEL_VERSION \
    -Dquarkus.container-image.additional-tags=latest \
    -Dquarkus.container-image.build=true \
    clean package
else
    if [ $SGX_DOCKERHUB_TYPE = "true" ]
    then
    ./mvnw \
    -Dquarkus.container-image.group=$SGX_DOCKER_GROUP \
    -Dquarkus.container-image.name=$SGX_SENTINEL_NAME \
    -Dquarkus.container-image.tag=$SGX_SENTINEL_VERSION \
    -Dquarkus.container-image.additional-tags=latest \
    -Dquarkus.container-image.push=true \
    clean package
    else
    ./mvnw \
    -Dquarkus.container-image.registry=$SGX_DOCKER_REGISTRY \
    -Dquarkus.container-image.group=$SGX_DOCKER_GROUP \
    -Dquarkus.container-image.username=$SGX_DOCKER_USER \
    -Dquarkus.container-image.password=$SGX_DOCKER_PASSWORD \
    -Dquarkus.container-image.name=$SGX_SENTINEL_NAME \
    -Dquarkus.container-image.tag=$SGX_SENTINEL_VERSION \
    -Dquarkus.container-image.additional-tags=latest \
    -Dquarkus.container-image.push=true \
    clean package
    fi
fi
retVal=$?
if [ $retVal -ne 0 ]; then
    exit $retval
fi
echo $SGX_SENTINEL_NAME:$SGX_SENTINEL_VERSION >> ../signomix/build-report.txt
fi

### signomix-reports
if [ -z "$2" ] || [ "$2" = "signomix-reports" ]; then
cd ../signomix-reports
./mvnw versions:set -DnewVersion=$SGX_REPORTS_VERSION
retVal=$?
if [ $retVal -ne 0 ]; then
    exit $retval
fi
if [ -z "$SGX_DOCKER_REGISTRY" ]
then
    echo
    ./mvnw \
    -Dquarkus.container-image.name=$SGX_REPORTS_NAME \
    -Dquarkus.container-image.tag=$SGX_REPORTS_VERSION \
    -Dquarkus.container-image.additional-tags=latest \
    -Dquarkus.container-image.build=true \
    clean package
else
    if [ $SGX_DOCKERHUB_TYPE = "true" ]
    then
    ./mvnw \
    -Dquarkus.container-image.group=$SGX_DOCKER_GROUP \
    -Dquarkus.container-image.name=$SGX_REPORTS_NAME \
    -Dquarkus.container-image.tag=$SGX_REPORTS_VERSION \
    -Dquarkus.container-image.additional-tags=latest \
    -Dquarkus.container-image.push=true \
    clean package
    else
    ./mvnw \
    -Dquarkus.container-image.registry=$SGX_DOCKER_REGISTRY \
    -Dquarkus.container-image.group=$SGX_DOCKER_GROUP \
    -Dquarkus.container-image.username=$SGX_DOCKER_USER \
    -Dquarkus.container-image.password=$SGX_DOCKER_PASSWORD \
    -Dquarkus.container-image.name=$SGX_REPORTS_NAME \
    -Dquarkus.container-image.tag=$SGX_REPORTS_VERSION \
    -Dquarkus.container-image.additional-tags=latest \
    -Dquarkus.container-image.push=true \
    clean package
    fi
fi
retVal=$?
if [ $retVal -ne 0 ]; then
    exit $retval
fi
echo $SGX_REPORTS_NAME:$SGX_REPORTS_VERSION >> ../signomix/build-report.txt
echo
fi

### signomix-lb but only if signomix-proxy2 exists
if [ -z "$2" ] || [ "$2" = "signomix-lb" ]; then
if [ -d "../signomix-lb" ]; then
cd ../signomix-lb
if [ -z "$SGX_DOCKER_REGISTRY" ]
then
    docker build --build-arg DOMAIN=$SGX_DOMAIN -t $SGX_LB_NAME:$SGX_LB_VERSION -t $SGX_LB_NAME:latest .
else
    if [ $SGX_DOCKERHUB_TYPE = "true" ]
    then
    docker build --build-arg DOMAIN=$SGX_DOMAIN -t $SGX_DOCKER_USER/$SGX_LB_NAME:$SGX_LB_VERSION -t $SGX_DOCKER_USER/$SGX_LB_NAME:latest .
    docker push $SGX_DOCKER_USER/$SGX_LB_NAME:$SGX_LB_VERSION
    docker push $SGX_DOCKER_USER/$SGX_LB_NAME:latest
    else
    docker build --build-arg DOMAIN=$SGX_DOMAIN -t $SGX_DOCKER_REGISTRY/$SGX_DOCKER_GROUP/$SGX_LB_NAME:$SGX_LB_VERSION -t $SGX_DOCKER_REGISTRY/$SGX_DOCKER_GROUP/$SGX_LB_NAME:latest .
    docker push $SGX_DOCKER_REGISTRY/$SGX_DOCKER_GROUP/$SGX_LB_NAME:$SGX_LB_VERSION
    docker push $SGX_DOCKER_REGISTRY/$SGX_DOCKER_GROUP/$SGX_LB_NAME:latest
    fi
fi
retVal=$?
if [ $retVal -ne 0 ]; then
    exit $retval
fi
echo $SGX_LB_NAME:$SGX_LB_VERSION >> ../signomix/build-report.txt
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
if [ -z "$SGX_DOCKER_REGISTRY" ]
then
    docker build -t $SGX_WEBSITE_NAME:$SGX_WEBSITE_VERSION -t $SGX_WEBSITE_NAME:latest .
else
    if [ $SGX_DOCKERHUB_TYPE = "true" ]
    then
    docker build -t $SGX_DOCKER_USER/$SGX_WEBSITE_NAME:$SGX_WEBSITE_VERSION -t $SGX_DOCKER_USER/$SGX_WEBSITE_NAME:latest .
    docker push $SGX_DOCKER_USER/$SGX_WEBSITE_NAME:$SGX_WEBSITE_VERSION
    docker push $SGX_DOCKER_USER/$SGX_WEBSITE_NAME:latest
    else
    docker build -t $SGX_DOCKER_REGISTRY/$SGX_DOCKER_GROUP/$SGX_WEBSITE_NAME:$SGX_WEBSITE_VERSION -t $SGX_DOCKER_REGISTRY/$SGX_DOCKER_GROUP/$SGX_WEBSITE_NAME:latest .
    docker push $SGX_DOCKER_REGISTRY/$SGX_DOCKER_GROUP/$SGX_WEBSITE_NAME:$SGX_WEBSITE_VERSION
    docker push $SGX_DOCKER_REGISTRY/$SGX_DOCKER_GROUP/$SGX_WEBSITE_NAME:latest
    fi
fi
retVal=$?
if [ $retVal -ne 0 ]; then
    exit $retval
fi
echo $SGX_WEBSITE_NAME:$SGX_WEBSITE_VERSION >> ../signomix/build-report.txt
echo
fi
fi

### saving images
cd ../signomix
./create-release-summary.sh $cfg_location

if [ -z "$SGX_DOCKER_REGISTRY" ]
then
    if [ $SGX_EXPORT_IMAGES != "true" ]
    then
    echo "image export skipped"
    else
    mkdir local-images
    rm local-images/*
    docker save $SGX_ACCOUNT_NAME:$SGX_ACCOUNT_VERSION | gzip > local-images/$SGX_ACCOUNT_NAME.tar.gz
    docker save $SGX_APP_NAME:$SGX_APP_VERSION | gzip > local-images/$SGX_APP_NAME.tar.gz
    docker save $SGX_MS_NAME:$SGX_MS_VERSION | gzip > local-images/$SGX_MS_NAME.tar.gz
    docker save $SGX_LB_NAME:$SGX_LB_VERSION | gzip > local-images/$SGX_LB_NAME.tar.gz
    docker save $SGX_GATEWAY_NAME:$SGX_GATEWAY_VERSION | gzip > local-images/$SGX_GATEWAY_NAME.tar.gz
    docker save $SGX_RECEIVER_NAME:$SGX_RECEIVER_VERSION | gzip > local-images/$SGX_RECEIVER_NAME.tar.gz
    docker save $SGX_PROVIDER_NAME:$SGX_PROVIDER_VERSION | gzip > local-images/$SGX_PROVIDER_NAME.tar.gz
    docker save $SGX_CORE_NAME:$SGX_CORE_VERSION | gzip > local-images/$SGX_CORE_NAME.tar.gz
    docker save $SGX_JOBS_NAME:$SGX_JOBS_VERSION | gzip > local-images/$SGX_JOBS_NAME.tar.gz
    docker save $SGX_AUTH_NAME:$SGX_AUTH_VERSION | gzip > local-images/$SGX_AUTH_NAME.tar.gz
    docker save $SGX_DOCS_NAME:$SGX_DOCS_VERSION | gzip > local-images/$SGX_DOCS_NAME.tar.gz
    docker save $SGX_VIEW_NAME:$SGX_VIEW_VERSION | gzip > local-images/$SGX_VIEW_NAME.tar.gz
    docker save $SGX_SENTINEL_NAME:$SGX_SENTINEL_VERSION | gzip > local-images/$SGX_SENTINEL_NAME.tar.gz
    docker save $SGX_REPORTS_NAME:$SGX_REPORTS_VERSION | gzip > local-images/$SGX_REPORTS_NAME.tar.gz
    echo "saved"
    fi
fi
# done

