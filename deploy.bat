@echo off

REM Set variables
set RESOURCE_GROUP=jenkins_test
set PLAN_NAME=myAppServicePlan
set WEBAPP_NAME=mb-app
set LOCATION=EastUS
set RUNTIME=PYTHON|3.9

REM Check if the resource group exists
echo Checking if the resource group exists...
az group show --name %RESOURCE_GROUP% > check_resource_group.log 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Resource group does not exist. Creating the resource group...
    az group create --name %RESOURCE_GROUP% --location %LOCATION% > create_resource_group.log 2>&1
    if %ERRORLEVEL% NEQ 0 (
        echo Failed to create the resource group. Check create_resource_group.log for details.
        type create_resource_group.log
        exit /b %ERRORLEVEL%
    )
)

REM Check if the app service plan exists
echo Checking if the app service plan exists...
az appservice plan show --name %PLAN_NAME% --resource-group %RESOURCE_GROUP% > check_plan.log 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo App service plan does not exist. Creating the app service plan...
    az appservice plan create --name %PLAN_NAME% --resource-group %RESOURCE_GROUP% --sku B1 --is-linux > create_plan.log 2>&1
    if %ERRORLEVEL% NEQ 0 (
        echo Failed to create the app service plan. Check create_plan.log for details.
        type create_plan.log
        exit /b %ERRORLEVEL%
    )
)

REM Check if the web app exists
echo Checking if the web app exists...
az webapp show --name %WEBAPP_NAME% --resource-group %RESOURCE_GROUP% > check_webapp.log 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Web app does not exist. Creating the web app...
    az webapp create --name %WEBAPP_NAME% --resource-group %RESOURCE_GROUP% --plan %PLAN_NAME% --runtime %RUNTIME% > create_webapp.log 2>&1
    if %ERRORLEVEL% NEQ 0 (
        echo Failed to create the web app. Check create_webapp.log for details.
        type create_webapp.log
        exit /b %ERRORLEVEL%
    )
)

REM Deploy the application
echo Deploying the application...
az webapp up --name %WEBAPP_NAME% --resource-group %RESOURCE_GROUP% --plan %PLAN_NAME% --runtime %RUNTIME% > deploy.log 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Deployment failed. Check deploy.log for details.
    type deploy.log
    exit /b %ERRORLEVEL%
)

echo Deployment complete.
