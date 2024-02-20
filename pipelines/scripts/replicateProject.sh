#!/bin/bash

#############################################################################
#                                                                           #
# replicateProject.sh : Publish & Deploy Project to maintain same id        #
#                                                                           #
#############################################################################

LOCAL_DEV_URL=$1
admin_user=$2
admin_password=$3
repoName=$4
destEnv=$5
destPort=$6
destUser=$7
assetID=$8
debug=${@: -1}

    if [ -z "$LOCAL_DEV_URL" ]; then
      echo "Missing template parameter LOCAL_DEV_URL"
      exit 1
    fi
    
    if [ -z "$admin_user" ]; then
      echo "Missing template parameter admin_user"
      exit 1
    fi

    if [ -z "$admin_password" ]; then
      echo "Missing template parameter admin_password"
      exit 1
    fi

    if [ -z "$repoName" ]; then
      echo "Missing template parameter repoName"
      exit 1
    fi
    if [ -z "$destEnv" ]; then
      echo "Missing template parameter destEnv"
      exit 1
    fi    
    if [ -z "$destPort" ]; then
      echo "Missing template parameter destPort"
      exit 1
    fi
    if [ -z "$destUser" ]; then
      echo "Missing template parameter destUser"
      exit 1
    fi
    if [ -z "$assetID" ]; then
      echo "Missing template parameter assetID"
      exit 1
    fi
 if [ "$debug" == "debug" ]; then
    echo "......Running in Debug mode ......"
  fi


function echod(){
  
  if [ "$debug" == "debug" ]; then
    echo $1
    set -x
  fi

}



PROJECT_URL=${LOCAL_DEV_URL}/apis/v1/rest/projects/${repoName}/push
echo "Publishing project ... "
json='{ "name": "'${repoName}'", "description": "Dummy Synch", "destination_tenant_detail": { "username": "'${destUser}'","password": "'${admin_password}'", "url": "https://'${destEnv}':'${destPort}'"},"flows": ["'${assetID}'"]}'


publishResponse=$(curl --location --request POST ${PROJECT_URL} \
--header 'Content-Type: application/json' \
--header 'Accept: application/json' \
--data-raw "$json" -u ${admin_user}:${admin_password})



versioncreated=$(echo "$publishResponse" | jq  '.output.version // empty')

if [ -z "$versioncreated" ];   then
    echo "Publish failed:" ${publishResponse}
    exit 1
else
    echo "Publish Succeeded:" ${publishResponse}
fi

LOCAL_DEV_URL=https://${destEnv}:${destPort}
PROJECT_URL=${LOCAL_DEV_URL}/apis/v1/rest/projects/${repoName}/deploy

json='{ "version": "'${versioncreated}'"}'

echo "Deploying project ... "
deployResponse=$(curl --location --request POST ${PROJECT_URL} \
--header 'Content-Type: application/json' \
--header 'Accept: application/json' \
--data-raw "$json" -u ${destUser}:${admin_password})



deployCreated=$(echo "$deployResponse" | jq  '.output.message // empty')


if [ -z "$versioncreated" ];   then
    echo "Deploy failed:" ${deployResponse}
    exit 1
else
    echo "Deploy Succeeded:" ${deployResponse}
fi
set +x


