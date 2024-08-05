echo off
setlocal

REM Define variables
set RESOURCE_GROUP=mbcicd
set PLAN_NAME=mb-service-plan
set WEBAPP_NAME=mb-app
set LOCATION=South Central US
set RUNTIME="PYTHON|3.11"
set OS_TYPE=linux

echo Checking if the resource group exists...
az group show --name %RESOURCE_GROUP% > check_resource_group.log 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Resource group %RESOURCE_GROUP% does not exist. Creating resource group...
    az group create --name %RESOURCE_GROUP% --location %LOCATION% > create_resource_group.log 2>&1
    if %ERRORLEVEL% NEQ 0 (
        echo Failed to create resource group. Check create_resource_group.log for details.
        type create_resource_group.log
        exit /b %ERRORLEVEL%
    )
)

echo Checking if the app service plan exists...
az appservice plan show --name %PLAN_NAME% --resource-group %RESOURCE_GROUP% > check_plan.log 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo App service plan %PLAN_NAME% does not exist. Creating app service plan...
    az appservice plan create --name %PLAN_NAME% --resource-group %RESOURCE_GROUP% --sku B1 --is-linux > create_plan.log 2>&1
    if %ERRORLEVEL% NEQ 0 (
        echo Failed to create app service plan. Check create_plan.log for details.
        type create_plan.log
        exit /b %ERRORLEVEL%
    )
)

echo Checking if the web app exists...
az webapp show --name %WEBAPP_NAME% --resource-group %RESOURCE_GROUP% > check_webapp.log 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Web app %WEBAPP_NAME% does not exist. Creating web app...
    az webapp create --name %WEBAPP_NAME% --resource-group %RESOURCE_GROUP% --plan %PLAN_NAME% --runtime %RUNTIME% > create_webapp.log 2>&1
    if %ERRORLEVEL% NEQ 0 (
        echo Failed to create web app. Check create_webapp.log for details.
        type create_webapp.log
        exit /b %ERRORLEVEL%
    )
)

echo Deploying the web app...
az webapp up --name %WEBAPP_NAME% --resource-group %RESOURCE_GROUP% --runtime %RUNTIME% > deploy.log 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Deployment failed with exit code %ERRORLEVEL%.
    type deploy.log
    exit /b %ERRORLEVEL%
) else (
    echo Deployment completed successfully.
    exit /b 0
)
