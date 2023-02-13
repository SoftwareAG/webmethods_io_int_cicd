#!/bin/sh
#############################################################################
#                                                                           #
# exportAsset.sh : Export asset from a project                    #
#                                                                           #
#############################################################################

LOCAL_DEV_URL=$1
admin_user=$2
admin_password=$3
repoName=$4
assetID=$5
assetType=$6
HOME_DIR=$7


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

    if [ -z "$assetID" ]; then
      echo "Missing template parameter assetID"
      exit 1
    fi

    if [ -z "$assetType" ]; then
      echo "Missing template parameter assetType"
      exit 1
    fi

    if [ -z "$HOME_DIR" ]; then
      echo "Missing template parameter HOME_DIR"
      exit 1
    fi
pwd
ls -ltr

echo ${assetType}

if [ "${assetType}" = "workflow" ]; then
        FLOW_URL=${LOCAL_DEV_URL}/apis/v1/rest/projects/${repoName}/workflows/${assetID}/export
        cd ${HOME_DIR}/${repoName}
        mkdir -p ./assets/workflows
        cd ./assets/workflows
        echo "Workflow Export:" ${FLOW_URL}
        ls -ltr
    else
        FLOW_URL=${LOCAL_DEV_URL}/apis/v1/rest/projects/${repoName}/flowservices/${assetID}/export
        cd ${HOME_DIR}/${repoName}
        mkdir -p ./assets/flowservices
        cd ./assets/flowservices
        echo "Flowservice Export:" ${FLOW_URL}
        ls -ltr
    fi    

    echo ${FLOW_URL}
    echo ${PWD}
    echo ${admin_user}:${admin_password}
    downloadURL=$(curl  --location --request POST ${FLOW_URL} \
    --header 'Content-Type: application/json' \
    --header 'Accept: application/json' \
    -u ${admin_user}:${admin_password}| jq -r '.output.download_link')
    
    regex='(https?|ftp|file)://[-[:alnum:]\+&@#/%?=~_|!:,.;]*[-[:alnum:]\+&@#/%=~_|]'
    
    if [[ $downloadURL =~ $regex ]]; then 
       echo ${downloadURL}
    else
        echo "Download link could not be retrieved"
        exit 1
    fi
    
    curl --location --request GET ${downloadURL} --output ${assetID}.zip
    