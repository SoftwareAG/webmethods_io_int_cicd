#!/bin/bash

#############################################################################
#                                                                            #
# readEnvs.sh : read number of environments from the congig directory        #
#                                                                            #
#############################################################################


CONFIG_DIR=$1
source_type=$2
debug=${@: -1}

    if [ -z "$CONFIG_DIR" ]; then
      echo "Missing template parameter CONFIG_DIR"
      exit 1
    fi

    if [ -z "$source_type" ]; then
      echo "Missing template parameter source_type"
      exit 1
    fi

    if [ "$debug" == "debug" ]; then
      set -x
      echo "......Running in Debug mode ......"
    fi


function echod(){
  if [ "$debug" == "debug" ]; then
    echo $1 
  fi

}
declare -a envArr
i=0
envs=''
shopt -s nullglob dotglob
env_files=($CONFIG_DIR/*.yml)
if [ ${#env_files[@]} -gt 0 ]; then
    for env in $CONFIG_DIR/*.yml; do 
        echod $env
        current_type=$(cat $env | yq -e '.tenant.type')
        if [ ${current_type} != ${source_type} ]; then
          envArr[i]=$(cat $env | yq -e '.tenant.type')
          echod $envArr[i]
          let i++
        fi    
    done
    envs=$(IFS=$','; echo "${envArr[*]}")
    
    echod $envs
else
    echo "No environment file found"
    exit 1
fi   

echo $envs

set +x


