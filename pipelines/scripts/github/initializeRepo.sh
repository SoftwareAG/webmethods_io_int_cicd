#!/bin/bash

#############################################################################
#                                                                           #
# initializeRepo.sh : Initialize Repo in GITHUB                    #
#                                                                           #
#############################################################################

repo_user=$1
PAT=$2
AZURE_TOKEN=$3
repoName=$4
devUser=$5
featureBranchName=$6
HOME_DIR=$7
debug=${@: -1}
gitHubApiURL=https://api.github.com/


    if [ -z "$repo_user" ]; then
      echo "Missing template parameter repo_user"
      exit 1
    fi
    
    if [ -z "$PAT" ]; then
      echo "Missing template parameter PAT"
      exit 1
    fi

    if [ -z "$AZURE_TOKEN" ]; then
      echo "Missing template parameter AZURE_TOKEN"
      exit 1
    fi

    if [ -z "$repoName" ]; then
      echo "Missing template parameter repoName"
      exit 1
    fi

    if [ -z "$devUser" ]; then
      echo "Missing template parameter devUser"
      exit 1
    fi

    if [ -z "$featureBranchName" ]; then
      echo "Missing template parameter featureBranchName"
      exit 1
    fi

    if [ -z "$HOME_DIR" ]; then
      echo "Missing template parameter HOME_DIR"
      exit 1
    fi
   
    if [ "$debug" == "debug" ]; then
      echo "......Running in Debug mode ......"
    fi

set -x
function echod(){
  
  if [ "$debug" == "debug" ]; then
    echo $1
    
  fi

}


name=$(curl -u ${repo_user}:${PAT} https://api.github.com/repos/${repo_user}/${repoName} | jq -r '.name')
      echo ${name}
      if [ "$name" == null ]
      then
          echo "Repo does not exists, creating ..."
          mkdir -p ${repoName}
          cd ${repoName}

          #### Create empty repo & SECRET
          curl -u ${repo_user}:${PAT} https://api.github.com/user/repos -d '{"name":"'${repoName}'"}'

          keyJson=$(curl -u ${repo_user}:${PAT} --location --request GET 'https://api.github.com/repos/${repo_user}/${repoName}/actions/secrets/public-key' \
          --header 'X-GitHub-Api-Version: 2022-11-28' \
          --header 'Accept: application/vnd.github+json')

          keyId=$(echo "$keyJson" | jq -r '.key_id')
          keyValue=$(echo "$keyJson" | jq -r '.key')
          token=$(echo ${AZURE_TOKEN})

          encryptedValue=$(python3.10 ../self/pipelines/scripts/github/encryptGithubSecret.py ${keyValue} ${token})
         

          secretJson='{"encrypted_value":"'"${encryptedValue}"'","key_id":"'"${keyId}"'"}'
          
          curl \
            -X PUT \
            -H "Accept: application/vnd.github+json" \
            -H "X-GitHub-Api-Version: 2022-11-28" \
            -u ${repo_user}:${PAT} https://api.github.com/repos/${repo_user}/${repoName}/actions/secrets/AZURE_DEVOPS_TOKEN \
            -d '{"encrypted_value":"'"${AZURE_TOKEN}"'","key_id":"'"${keyId}"'"}'
          
          #### Initiatialite and push to main
          echo "# ${repoName}" >> README.md
          mkdir -p .github
          cd .github
          mkdir -p workflows
          cd ..
          cp ../self/assets/github/workflows/dev.yml .github/workflows/
          git init
          git config user.email "noemail.com"
          git config user.name "${devUser}"
          git add .
          git commit -m "first commit"
          git branch -M production
          git remote add origin https://${repo_user}:${PAT}@github.com/${repo_user}/${repoName}.git
          git push -u origin production

          git checkout -b dev production
          git commit -m "first commit"
          git push -u origin dev

          git checkout -b qa production
          git commit -m "first commit"
          git push -u origin qa
          
          git checkout -b ${featureBranchName} production
          git commit -m "first commit"
          git push -u origin ${featureBranchName}

          #Enable workflow
           curl -u ${repo_user}:${PAT} -X PUT \
              -H "Accept: application/vnd.github+json" \
             -H "X-GitHub-Api-Version: 2022-11-28" \
             https://api.github.com/repos/${repo_user}/${repoName}/actions/workflows/dev.yml/enable

          echo "Repo creation done !!!"
      else
          echo "Repo already exixts with name:" ${name}
          echo "##vso[task.setvariable variable=init]false"
          exit 0
      fi