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

REM Use timeout to wait for 5 seconds
REM timeout /t 5 /nobreak

REM Deploy the app
az webapp up --name %WEBAPP_NAME% --resource-group %RESOURCE_GROUP% --runtime %RUNTIME%

REM Check if the deployment was successful
if %ERRORLEVEL% NEQ 0 (
    echo Deployment failed with exit code %ERRORLEVEL%.
    exit /b %ERRORLEVEL%
) else (
    echo Deployment completed successfully.
    exit /b 0
)