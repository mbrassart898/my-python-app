@echo off
setlocal

REM Define variables
set RESOURCE_GROUP=jenkins_test
set PLAN_NAME=myAppServicePlan
set WEBAPP_NAME=mb-app
set LOCATION=EastUS
set RUNTIME="PYTHON|3.11"
set OS_TYPE=linux

REM Function to check the last executed command status
:check_error
if %errorlevel% neq 0 (
    echo Error: Command failed with error code %errorlevel%
    exit /b %errorlevel%
)

echo Checking if the resource group exists...
az group show --name %RESOURCE_GROUP% > check_resource_group.log 2>&1
if %errorlevel% neq 0 (
    echo Resource group %RESOURCE_GROUP% does not exist. Creating resource group...
    az group create --name %RESOURCE_GROUP% --location %LOCATION% > create_resource_group.log 2>&1
    call :check_error
)

echo Checking if the app service plan exists...
az appservice plan show --name %PLAN_NAME% --resource-group %RESOURCE_GROUP% > check_plan.log 2>&1
if %errorlevel% neq 0 (
    echo App service plan %PLAN_NAME% does not exist. Creating app service plan...
    az appservice plan create --name %PLAN_NAME% --resource-group %RESOURCE_GROUP% --sku B1 --is-linux > create_plan.log 2>&1
    call :check_error
)

echo Checking if the web app exists...
az webapp show --name %WEBAPP_NAME% --resource-group %RESOURCE_GROUP% > check_webapp.log 2>&1
if %errorlevel% neq 0 (
    echo Web app %WEBAPP_NAME% does not exist. Creating web app...
    az webapp create --name %WEBAPP_NAME% --resource-group %RESOURCE_GROUP% --plan %PLAN_NAME% --runtime %RUNTIME% > create_webapp.log 2>&1
    call :check_error
)

echo Deploying the web app...
az webapp up --name %WEBAPP_NAME% --resource-group %RESOURCE_GROUP% --runtime %RUNTIME% > deploy.log 2>&1
call :check_error

echo Deployment completed successfully.
exit /b 0
