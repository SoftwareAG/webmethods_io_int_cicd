   pwd
    cd ../self
    pwd
    ls -ltr
    echo "##vso[task.setvariable variable=source_environment_hostname]`yq -e ".tenant.hostname" configs/dev.yml`"
    echo "##vso[task.setvariable variable=source_environment_port]`yq -e ".tenant.port" configs/dev.yml`"
    echo "##vso[task.setvariable variable=exporter_user]`yq -e ".tenant.exporter_username" configs/dev.yml`"
    echo "##vso[task.setvariable variable=source_type]`yq -e ".tenant.type" configs/dev.yml`"
    PROJECTNAME=$(perl -MURI::Escape -e 'print uri_escape($ARGV[0]);' "$PROJECTNAME")
    echo ${PROJECTNAME}
    echo "##vso[build.updatebuildnumber]$(Build.BuildNumber)-${PROJECTNAME}"
    echo $(System.DefaultWorkingDirectory)