#!/bin/bash
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
synchProject=$8
source_type=$9
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

  if [ "$debug" == "debug" ]; then
    echo "......Running in Debug mode ......"
  fi

      if [ -z "$source_type" ]; then
      echo "Missing template parameter source_type"
      exit 1
    fi


function echod(){
  
  if [ "$debug" == "debug" ]; then
    echo $1
  fi

}

function exportAsset(){

LOCAL_DEV_URL=$1
admin_user=$2
admin_password=$3
repoName=$4
assetID=$5
assetType=$6
HOME_DIR=$7

echod ${assetType}

if [[ $assetType = workflow* ]]; then
        echod $assetType
        FLOW_URL=${LOCAL_DEV_URL}/apis/v1/rest/projects/${repoName}/workflows/${assetID}/export
        cd ${HOME_DIR}/${repoName}
        mkdir -p ./assets/workflows
        cd ./assets/workflows
        echod "Workflow Export:" ${FLOW_URL}
        echod $(ls -ltr)
    else
        FLOW_URL=${LOCAL_DEV_URL}/apis/v1/rest/projects/${repoName}/flows/${assetID}/export
        cd ${HOME_DIR}/${repoName}
        mkdir -p ./assets/flowservices
        cd ./assets/flowservices
        echo "Flowservice Export:" ${FLOW_URL}
        echod $(ls -ltr)
    fi    

  
    linkJson=$(curl  --location --request POST ${FLOW_URL} \
    --header 'Content-Type: application/json' \
    --header 'Accept: application/json' \
    -u ${admin_user}:${admin_password})

    downloadURL=$(echo "$linkJson" | jq -r '.output.download_link')
    
    regex='(https?|ftp|file)://[-[:alnum:]\+&@#/%?=~_|!:,.;]*[-[:alnum:]\+&@#/%=~_|]'
    
    if [[ $downloadURL =~ $regex ]]; then 
       echod "Valid Download link retreived:"${downloadURL}
    else
        echo "Download link retreival Failed:" ${linkJson}
        exit 1
    fi
    downloadJson=$(curl --location --request GET "${downloadURL}" --output ${assetID}.zip)

    FILE=./${assetID}.zip
    if [ -f "$FILE" ]; then
        echo "Download succeeded:" ls -ltr ./${assetID}.zip
    else
        echo "Download failed:"${downloadJson}
    fi
cd ${HOME_DIR}/${repoName}

}  
if [ ${synchProject} == true ]; then
  echod "Listing All Assets"
  echod $assetType
  PROJECT_LIST_URL=${LOCAL_DEV_URL}/apis/v1/rest/projects/${repoName}/assets

  projectListJson=$(curl  --location --request GET ${PROJECT_LIST_URL} \
    --header 'Content-Type: application/json' \
    --header 'Accept: application/json' \
    -u ${admin_user}:${admin_password})
  
  # Exporing Workflows
  for item in $(jq  -c -r '.output.workflows[]' <<< "$projectListJson"); do
    echod "Inside Workflow Loop"
    assetID=$item
    assetType=workflow
    echod $assetID
    exportAsset ${LOCAL_DEV_URL} ${admin_user} ${admin_password} ${repoName} ${assetID} ${assetType} ${HOME_DIR}
  done
  # Exporting Flows
  for item in $(jq  -c -r '.output.flows[]' <<< "$projectListJson"); do
    echod "Inside FS Loop"
    assetID=$item
    assetType=flowservice
    echod $assetID
    exportAsset ${LOCAL_DEV_URL} ${admin_user} ${admin_password} ${repoName} ${assetID} ${assetType} ${HOME_DIR}
  done
else
  exportAsset ${LOCAL_DEV_URL} ${admin_user} ${admin_password} ${repoName} ${assetID} ${assetType} ${HOME_DIR} 
fi  

#Expoting Accounts
ACCOUNT_LIST_URL=${LOCAL_DEV_URL}/apis/v1/rest/projects/${repoName}/accounts

accountListJson=$(curl  --location --request GET ${ACCOUNT_LIST_URL} \
    --header 'Content-Type: application/json' \
    --header 'Accept: application/json' \
    -u ${admin_user}:${admin_password})


    accountexport=$(echo "$accountListJson" | jq '. // empty')
      if [ -z "$accountexport" ];   then
          echo "Account export failed:" ${accountListJson}
      else
          
          mkdir -p ./assets/accounts
          cd ./assets/accounts
          echo "$accountListJson" > user_accounts.json
          echo "Account export Succeeded"
      fi
cd ${HOME_DIR}/${repoName}


set -x
# Exporting Project Referencedata
PROJECT_ID_URL=${LOCAL_DEV_URL}/apis/v1/rest/projects/${repoName}

projectJson=$(curl  --location --request GET ${PROJECT_ID_URL} \
    --header 'Content-Type: application/json' \
    --header 'Accept: application/json' \
    -u ${admin_user}:${admin_password})


projectID=$(echo "$projectJson" | jq -r -c '.output.uid // empty')

if [ -z "$projectID" ];   then
    echo "Incorrect Project/Repo name"
    exit 1
fi

echod "ProjectID:" ${projectID}

PROJECT_REF_DATA_LIST_URL=${LOCAL_DEV_URL}/integration/rest/external/v1/ut-flow/referencedata/${projectID}

rdListJson=$(curl --location --request GET ${PROJECT_REF_DATA_LIST_URL}  \
--header 'Content-Type: application/json' \
--header 'Accept: application/json' \
-u ${admin_user}:${admin_password})

rdListExport=$(echo "$rdListJson" | jq -r -c '.integration.serviceData.referenceData[].name // empty')

if [ -z "$rdListExport" ];   then
          echo "No reference data defined for the project" 
      else
          mkdir -p ./assets/projectConfigs/referenceData
          cd ./assets/projectConfigs/referenceData
          for item in $(jq -r '.integration.serviceData.referenceData[] | .name' <<< "$rdListJson"); do
            echod "Inside Ref Data Loop:" "$item"
            rdName=${item}
            REF_DATA_URL=${LOCAL_DEV_URL}/integration/rest/external/v1/ut-flow/referencedata/${projectID}/${rdName}
            rdJson=$(curl --location --request GET ${REF_DATA_URL}  \
            --header 'Content-Type: application/json' \
            --header 'Accept: application/json' \
            -u ${admin_user}:${admin_password})
            rdExport=$(echo "$rdJson" | jq '. // empty')
            if [ -z "$rdExport" ];   then
              echo "Empty reference data defined for the name:" ${rdName}
            else
              columnDelimiter=$(echo "$rdJson" | jq -c -r '.integration.serviceData.referenceData.columnDelimiter')
              if [[ "$columnDelimiter" == "," ]]; then
                echod "COMMA"
                datajson=$(echo "$rdJson" | jq -c -r '(map(keys) | add | unique) as $cols | map(. as $row | $cols | map($row[.])) as $rows | $cols, $rows[] | @csv')
              else
                echod "Not a COMMA:" ${columnDelimiter}
                datajson=$(echo "$rdJson" | jq -c -r '(map(keys) | add | unique) as $cols | map(. as $row | $cols | map($row[.])) as $rows | $cols, $rows[] | @csv' | sed "s/\",\"/\"${columnDelimiter}\"/g")
              fi

              echod "${datajson}"
              mkdir -p ${rdName}
              cd ${rdName}
              
              metadataJson=$(echo "$rdJson" | jq -c -r '.integration.serviceData.referenceData')
              metadataJson=$(echo "$rdJson"| jq 'del(.columnNames, .dataRecords, .revisionData)')
              echo "$metadataJson" > $metadata.json
              echo "$datajson" > ${source_type}.csv
              cp .${source_type}.csv dev.csv qa.csv prod.csv
            fi
          done
        echo "Reference Data export Succeeded"
      fi
cd ${HOME_DIR}/${repoName}

set +x
# Exporting Project Parameters
: ' PP Export
PROJECT_PARAM_GET_URL=${LOCAL_DEV_URL}/apis/v1/rest/projects/${repoName}/params

ppListJson=$(curl --location --request GET ${PROJECT_PARAM_GET_URL}  \
--header 'Content-Type: application/json' \
--header 'Accept: application/json' \
-u ${admin_user}:${admin_password})

ppListExport=$(echo "$ppListJson" | jq '. // empty')

if [ -z "$ppListExport" ];   then
          echo "No Project Parameters retreived:" ${ppListJson}
      else
          mkdir -p ./assets/projectConfigs/parameters
          cd ./assets/projectConfigs/parameters
          for item in $(jq  -c -r '.output[]' <<< "$ppListJson"); do
            echod "Inside Parameters Loop"
            parameterUID=$(jq -r '.uid' <<< "$item")
            data=$(jq -r '.param' <<< "$item")
            echo ${data} > ./${parameterUID}.json
          done
        echo "Project Parameters export Succeeded"
      fi
cd ${HOME_DIR}/${repoName}
'
