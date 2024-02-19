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
assetID=$5
assetType=$6
deleteProject=$7
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
    if [ -z "$assetType" ]; then
      echo "Missing template parameter assetType"
      exit 1
    fi    
    if [ -z "$deleteProject" ]; then
      echo "Missing template parameter deleteProject"
      exit 1
    fi
    if [ -z "$assetID" ]; then
      echo "Missing template parameter destEnv"
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

function deleteAsset(){

  LOCAL_DEV_URL=$1
  admin_user=$2
  admin_password=$3
  repoName=$4
  assetID=$5
  assetType=$6
  

 
  if [[ $assetType = workflow* ]]; then
      echod $assetType
      DELETE_URL=${LOCAL_DEV_URL}/apis/v1/rest/projects/${repoName}/workflows/${assetID}
      echod "Workflow Delete:" ${DELETE_URL}
  else
    if [[ $assetType = flowservice* ]]; then
      DELETE_URL=${LOCAL_DEV_URL}/apis/v1/rest/projects/${repoName}/flows/${assetID}
      echod "Flowservice Delete:" ${DELETE_URL}
    fi
  fi

  echo "Deleting "${assetType}" in project: "${repoName}

  deleteJson=$(curl  --location --request DELETE ${DELETE_URL} \
      --header 'Content-Type: application/json' \
      --header 'Accept: application/json' \
      -u ${admin_user}:${admin_password} | jq -r '.output.message // empty')
  
  echod ${deleteJson}

}


if [ ${deleteProject} == true ]; then
  echo "Listing All Assets"

  PROJECT_LIST_URL=${LOCAL_DEV_URL}/apis/v1/rest/projects/${repoName}/assets
  echo "Listing assets in project ... "

  projectListJson=$(curl --location --request GET ${PROJECT_LIST_URL} \
  --header 'Content-Type: application/json' \
  --header 'Accept: application/json' \
  -u ${admin_user}:${admin_password})

  echod ${projectListJson}


 # Deleting Workflows
  for item in $(jq  -c -r '.output.workflows[]' <<< "$projectListJson"); do
    echod "Inside Workflow Loop"
    assetID=$item
    assetType=workflow
    echod $assetID
    deleteAsset ${LOCAL_DEV_URL} ${admin_user} ${admin_password} ${repoName} ${assetID} workflow
  done

  echo "Listing assets in project ... "
  projectListJson=$(curl --location --request GET ${PROJECT_LIST_URL} \
  --header 'Content-Type: application/json' \
  --header 'Accept: application/json' \
  -u ${admin_user}:${admin_password})

  echod ${projectListJson}

  # Deleting Flows
  for item in $(jq  -c -r '.output.flows[]' <<< "$projectListJson"); do
    echod "Inside FS Loop"
    assetID=$item
    assetType=flowservice
    echod $assetID
    deleteAsset ${LOCAL_DEV_URL} ${admin_user} ${admin_password} ${repoName} ${assetID} flowservice
  done
else
  echod "Single asset delete ..."
  deleteAsset ${LOCAL_DEV_URL} ${admin_user} ${admin_password} ${repoName} ${assetID} ${assetType}
fi


set +x


