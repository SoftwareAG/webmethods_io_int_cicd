   pwd
    cd ../self
    pwd
    ls -ltr
    echo "##vso[task.setvariable variable=source_environment_hostname]`yq -e ".tenant.hostname" configs/env/dev.yml`"
    echo "##vso[task.setvariable variable=source_environment_port]`yq -e ".tenant.port" configs/env/dev.yml`"
    echo "##vso[task.setvariable variable=exporter_user]`yq -e ".tenant.exporter_username" configs/env/dev.yml`"
    echo "##vso[task.setvariable variable=source_type]`yq -e ".tenant.type" configs/env/dev.yml`"
    PROJECTNAME=$(perl -MURI::Escape -e 'print uri_escape($ARGV[0]);' "$PROJECTNAME")
    echo "##vso[build.updatebuildnumber]$(Build.BuildNumber)-${PROJECTNAME}"
    