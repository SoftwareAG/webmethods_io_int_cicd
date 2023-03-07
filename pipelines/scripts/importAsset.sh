
#!/bin/bash

#############################################################################
#                                                                           #
# importAsset.sh : Import asset into a project                    #
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
        if [ -z "$source_type" ]; then
      echo "Missing template parameter source_type"
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

function importAsset() {
  LOCAL_DEV_URL=$1
  admin_user=$2
  admin_password=$3
  repoName=$4
  assetID=$5
  assetType=$6
  HOME_DIR=$7
  synchProject=$8

  echod $(pwd)
  echod $(ls -ltr)
  echo "AssetType:" $assetType
  if [[ $assetType = workflow* ]]; then
      FLOW_URL=${LOCAL_DEV_URL}/apis/v1/rest/projects/${repoName}/workflow-import
      cd ${HOME_DIR}/${repoName}/assets/workflows
      echod "Workflow Import:" ${FLOW_URL}
      echod $(ls -ltr)
  else
      FLOW_URL=${LOCAL_DEV_URL}/apis/v1/rest/projects/${repoName}/flow-import
      cd ${HOME_DIR}/${repoName}/assets/flowservices
      echod "Flowservice Import:" ${FLOW_URL}
      echod $(ls -ltr)
  fi    
      echod ${FLOW_URL}
      echod ${PWD}
  FILE=./${assetID}.zip
  formKey="recipe=@"${FILE}
  echod ${formKey}
  if [ -f "$FILE" ]; then
  ####### Check if asset with this name exist

      echo "$FILE exists. Importing ..."
      importedName=$(curl --location --request POST ${FLOW_URL} \
                  --header 'Content-Type: multipart/form-data' \
                  --header 'Accept: application/json' \
                  --form ${formKey} -u ${admin_user}:${admin_password})    

      name=$(echo "$importedName" | jq '.output.name // empty')
      if [ -z "$name" ];   then
          echo "Import failed:" ${importedName}
      else
          echo "Import Succeeded:" ${importedName}
      
      fi
  else
    echo "$FILE does not exists, Nothing to import"
  fi
cd ${HOME_DIR}/${repoName}
}

function refData(){
  LOCAL_DEV_URL=$1
  admin_user=$2
  admin_password=$3
  repoName=$4
  assetID=$5
  assetType=$6
  HOME_DIR=$7
  synchProject=$8
  source_type=$9

# Importing Reference Data
  DIR="./assets/projectConfigs/referenceData/"
  if [ -d "$DIR" ]; then
      echo "Project referenceData needs to be synched"
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
      cd ./assets/projectConfigs/referenceData/
      for d in * ; do
          if [ -d "$d" ]; then
            refDataName="$d"
            echod "$d"
            cd "$d"
            description=$(jq -r .description metadata.json)
            columnDelimiter=$(jq -r .columnDelimiter metadata.json)
            encodingType=$(jq -r .encodingType metadata.json)
            releaseCharacter=$(jq -r .releaseCharacter metadata.json)
            FILE=./${source_type}.csv
            formKey="file=@"${FILE}
            echod ${formKey} 
            REF_DATA_URL=${LOCAL_DEV_URL}/integration/rest/external/v1/ut-flow/referencedata/${projectID}/${refDataName}
            rdJson=$(curl --location --request GET ${REF_DATA_URL}  \
              --header 'Content-Type: application/json' \
              --header 'Accept: application/json' \
              -u ${admin_user}:${admin_password})
              rdExport=$(echo "$rdJson" | jq '.integration.serviceData.referenceData // empty')
              if [ -z "$rdExport" ];   then
                echo "Refrence Data does not exists, Creating ....:" ${refDataName}
                POST_REF_DATA_URL=${LOCAL_DEV_URL}/integration/rest/external/v1/ut-flow/referencedata/create/${projectID}                 
              else
                echo "Refrence Data exists, Updating ....:" ${refDataName}
                POST_REF_DATA_URL=${LOCAL_DEV_URL}/integration/rest/external/v1/ut-flow/referencedata/update/${projectID}/${refDataName}
              fi
              projectPostJson=$(curl --location --request POST ${POST_REF_DATA_URL} \
                  --header 'Accept: application/json' \
                  --form 'name='"$refDataName" \
                  --form 'description='"$description" \
                  --form 'field separator='"$columnDelimiter" \
                  --form 'text qualifier='"$releaseCharacter" \
                  --form 'file encoding='"$encodingType" \
                  --form ${formKey} -u ${admin_user}:${admin_password})  
             refDataOutput=$(echo "$projectPostJson" | jq -r -c '.integration.message.description')
             if [ "$refDataOutput"=="Success" ];   then
                echo "Reference Data created/updated successfully"
             else
                echo "Reference Data failed:" ${projectPostJson}
            fi

          fi
      done

cd ${HOME_DIR}/${repoName}

}


function projectParameters(){
# Importing Project Parameters
  LOCAL_DEV_URL=$1
  admin_user=$2
  admin_password=$3
  repoName=$4
  assetID=$5
  assetType=$6
  HOME_DIR=$7
  synchProject=$8
  source_type=$9
  echod $(pwd)
  echod $(ls -ltr)

  DIR="./assets/projectConfigs/parameters/"
  if [ -d "$DIR" ]; then
      echo "Project Parameters needs to be synched"
      cd ./assets/projectConfigs/parameters/
      for filename in ./*.json; do
          parameterUID=${filename##*/}
          parameterUID=${parameterUID%.*}
          echod ${parameterUID}
          PROJECT_PARAM_GET_URL=${LOCAL_DEV_URL}/apis/v1/rest/projects/${repoName}/params/${parameterUID}
          echod ${PROJECT_PARAM_GET_URL}
          ppListJson=$(curl --location --request GET ${PROJECT_PARAM_GET_URL}  \
          --header 'Content-Type: application/json' \
          --header 'Accept: application/json' \
          -u ${admin_user}:${admin_password})

          ppExport=$(echo "$ppListJson" | jq '.output.uid // empty')
          echod ${ppExport}
          if [ -z "$ppExport" ];   then
              echo "Project parameters does not exists, creating ..:"
              PROJECT_PARAM_CREATE_URL=${LOCAL_DEV_URL}/apis/v1/rest/projects/${repoName}/params
              echod ${PROJECT_PARAM_CREATE_URL}
              parameterJSON="$(cat ${parameterUID}.json)"
              echod "${parameterJSON}"
              echod "curl --location --request POST ${PROJECT_PARAM_CREATE_URL}  \
              --header 'Content-Type: application/json' \
              --header 'Accept: application/json' \
              --data-raw "$parameterJSON" -u ${admin_user}:${admin_password})"

              ppCreateJson=$(curl --location --request POST ${PROJECT_PARAM_CREATE_URL}  \
              --header 'Content-Type: application/json' \
              --header 'Accept: application/json' \
              --data-raw "$parameterJSON" -u ${admin_user}:${admin_password})
              ppCreatedJson=$(echo "$ppCreateJson" | jq '.output.uid // empty')
              if [ -z "$ppCreatedJson" ];   then
                  echo "Project Paraters Creation failed:" ${ppCreateJson}
              else
                  echo "Project Paraters Creation Succeeded, UID:" ${ppCreatedJson}
              fi
          else
              echo "Project parameters does exists, updating ..:"
              PROJECT_PARAM_UPDATE_URL=${LOCAL_DEV_URL}/apis/v1/rest/projects/${repoName}/params/${parameterUID}
              echod ${PROJECT_PARAM_UPDATE_URL}
              parameterJSON=`jq '.' ${parameterUID}.json`
              echod ${parameterJSON}
              ppUpdateJson=$(curl --location --request POST ${PROJECT_PARAM_UPDATE_URL}  \
              --header 'Content-Type: application/json' \
              --header 'Accept: application/json' \
              -d ${parameterJSON} -u ${admin_user}:${admin_password})
              ppUpdatedJson=$(echo "$ppUpdateJson" | jq '.output.uid // empty')
              if [ -z "$ppUpdatedJson" ];   then
                  echo "Project Paraters Creation failed:" ${ppUpdateJson}
              else
                  echo "Project Paraters Creation Succeeded, UID:" ${ppUpdatedJson}
              fi       
          fi
      done
  else 
      echo "No Project Parameters to import."
  fi

  cd ${HOME_DIR}/${repoName}
  

}


if [ ${synchProject} == true ]; then
  echod "Listing files"
  for filename in ./assets/*/*.zip; do 
      base_name=${filename##*/}
      parent_name="$(basename "$(dirname "$filename")")"
      base_name=${base_name%.*}
      echod $base_name${filename%.*}
      echod $parent_name
      importAsset ${LOCAL_DEV_URL} ${admin_user} ${admin_password} ${repoName} ${base_name} ${parent_name} ${HOME_DIR} ${synchProject}
  done
  
  refData ${LOCAL_DEV_URL} ${admin_user} ${admin_password} ${repoName} ${base_name} ${parent_name} ${HOME_DIR} ${synchProject} ${source_type}
  #projectParameters ${LOCAL_DEV_URL} ${admin_user} ${admin_password} ${repoName} ${base_name} ${parent_name} ${HOME_DIR} ${synchProject} ${source_type}

else
  importAsset ${LOCAL_DEV_URL} ${admin_user} ${admin_password} ${repoName} ${assetID} ${assetType} ${HOME_DIR} 
fi 
set +x