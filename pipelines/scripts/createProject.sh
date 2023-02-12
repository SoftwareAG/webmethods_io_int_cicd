#!/bin/sh

#############################################################################
#                                                                           #
# createProject.sh : Creates Project if does not exists                     #
#                                                                           #
#############################################################################

PROJECT_URL=$1
exporter_user=$2
exporter_password=$3
repoName=$4

    if [ -z "$PROJECT_URL" ]; then
      echo "Missing template parameter PROJECT_URL"
      exit 1
    fi
    
    if [ -z "$exporter_user" ]; then
      echo "Missing template parameter exporter_user"
      exit 1
    fi

    if [ -z "$exporter_password" ]; then
      echo "Missing template parameter exporter_password"
      exit 1
    fi

    if [ -z "$repoName" ]; then
      echo "Missing template parameter repoName"
      exit 1
    fi

echo "URL:" ${PROJECT_URL}
echo "exporter_user:" ${exporter_user}
echo "exporter_password:" ${exporter_password}
echo "repoName:" ${repoName}




echo "Check Project exists"
        name=$(curl --location --request GET ${PROJECT_URL} \
                --header 'Accept: application/json' \
                -u ${exporter_user}:${exporter_password} | jq -r '.output.name // empty')
        echo ${name}
        if [[ ! -z "$name" ]]; then; then
            echo "Project does not exists, creating ..."
            #### Create project in the tenant
            json='{ "name": "' ${repoName}'", "description": "Created by Automated CI for feature branch"}'
            projectName=$(curl --location --request POST ${PROJECT_URL} \
            --header 'Content-Type: application/json' \
            --header 'Accept: application/json' \
            --data-raw "$json" -u ${exporter_user}:${exporter_password}| jq -r '.')
        else
            echo "Projecxt already exixts with name:" ${name}
            exit 0
        fi