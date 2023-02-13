#!/bin/sh

#############################################################################
#                                                                           #
# createProject.sh : Creates Project if does not exists                     #
#                                                                           #
#############################################################################

LOCAL_DEV_URL=$1
admin_user=$2
admin_password=$3
repoName=$4


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


PROJECT_URL=${LOCAL_DEV_URL}/apis/v1/rest/projects/${repoName}

echo "Check Project exists"
name=$(curl --location --request GET ${PROJECT_URL} \
        --header 'Accept: application/json' \
        -u ${admin_user}:${admin_password} | jq -r '.output.name // empty')

if [ -z "$name" ];   then
    echo "Project does not exists. Creating ..."
    #### Create project in the tenant
    json='{ "name": "'${repoName}'", "description": "Created by Automated CI for feature branch"}'
    projectName=$(curl --location --request POST ${PROJECT_URL} \
    --header 'Content-Type: application/json' \
    --header 'Accept: application/json' \
    --data-raw "$json" -u ${admin_user}:${admin_password})

    namecreated=echo $json | jq -r '.output.name // empty'

    if [ ! -z "$namecreated" ]; then
        echo "Project created successfully:" ${json}
    else
        echo "Project creation failed:" ${json}
        exit 1
    fi
else
    echo "Project already exixts with name:" ${name}
    exit 0
fi