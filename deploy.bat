@echo off
setlocal

REM Set variables
set AZURE_APP_NAME=mb-app
set AZURE_RESOURCE_GROUP=jenkins_test
set AZURE_PLAN_NAME=myAppServicePlan
set AZURE_LOCATION=EastUS

REM Check if the resource group exists
echo Checking if the resource group exists...
az group show --name %AZURE_RESOURCE_GROUP% >check_resource_group.log 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo The resource group '%AZURE_RESOURCE_GROUP%' does not exist. Creating the resource group...
    az group create --name %AZURE_RESOURCE_GROUP% --location %AZURE_LOCATION% >create_resource_group.log 2>&1
    if %ERRORLEVEL% NEQ 0 (
        echo Failed to create the resource group. Check create_resource_group.log for details.
        type create_resource_group.log
        exit /b %ERRORLEVEL%
    )
)

REM Check if the app service plan exists
echo Checking if the app service plan exists...
az appservice plan show --name %AZURE_PLAN_NAME% --resource-group %AZURE_RESOURCE_GROUP% >check_plan.log 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo The app service plan '%AZURE_PLAN_NAME%' does not exist. Creating the app service plan...
    az appservice plan create --name %AZURE_PLAN_NAME% --resource-group %AZURE_RESOURCE_GROUP% --sku B1 >create_plan.log 2>&1
    if %ERRORLEVEL% NEQ 0 (
        echo Failed to create the app service plan. Check create_plan.log for details.
        type create_plan.log
        exit /b %ERRORLEVEL%
    )
)

REM Check if the web app exists
echo Checking if the web app exists...
az webapp show --name %AZURE_APP_NAME% --resource-group %AZURE_RESOURCE_GROUP% >check_webapp.log 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo The web app '%AZURE_APP_NAME%' does not exist. Creating the web app...
    az webapp create --name %AZURE_APP_NAME% --resource-group %AZURE_RESOURCE_GROUP% --plan %AZURE_PLAN_NAME% >create_webapp.log 2>&1
    if %ERRORLEVEL% NEQ 0 (
        echo Failed to create the web app. Check create_webapp.log for details.
        type create_webapp.log
        exit /b %ERRORLEVEL%
    )
)

REM Deploy the web app
echo Deploying to Azure Web App...
az webapp up --name %AZURE_APP_NAME% --resource-group %AZURE_RESOURCE_GROUP% --plan %AZURE_PLAN_NAME% --runtime "PYTHON|3.9" >deploy.log 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Deployment failed. Check deploy.log for details.
    type deploy.log
    exit /b %ERRORLEVEL%
)

echo Deployment complete.
endlocal
