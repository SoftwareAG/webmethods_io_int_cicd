#!/bin/bash

#################################################################################
#                                                                               #
# createFeatureFromProdBranch.sh : Create Feature Branch from Production Branch #
#                                                                               #
#################################################################################

devUser=$1
featureBranchName=$2
HOME_DIR=$3
debug=${@: -1}



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


              # Creating Feature Branch 
              echo "Branch does not exists. Creating Branch ..."
              git config user.email "noemail.com"
              git config user.name "${devUser}"
              git checkout -b ${featureBranchName} production
              git add .
              git commit -m "Synching from Prod for feature branch ${featureBranchName}"
              git push -u origin ${featureBranchName}
set +x