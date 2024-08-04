echo off
setlocal

REM Define variables
set RESOURCE_GROUP=mbcicd
set PLAN_NAME=mb-service-plan
set WEBAPP_NAME=mb-app
set LOCATION=South Central US
set RUNTIME="PYTHON|3.11"
set OS_TYPE=linux


echo Deploying the web app...
az webapp up --name %WEBAPP_NAME% --resource-group %RESOURCE_GROUP% --runtime %RUNTIME%


echo Deployment completed successfully.
exit /b 0
