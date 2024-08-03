@echo off
setlocal

echo Checking if the web app exists...
az webapp show --name your-azure-app-url --resource-group jenkins_test >nul 2>&1

if %ERRORLEVEL% NEQ 0 (
    echo The web app 'your-azure-app-url' does not exist. Creating the web app...
    az webapp create --name your-azure-app-url --resource-group jenkins_test --plan myAppServicePlan
    if %ERRORLEVEL% NEQ 0 (
        echo Failed to create the web app. Exiting.
        exit /b %ERRORLEVEL%
    )
)

echo Deploying to Azure Web App...
az webapp up --name your-azure-app-url --runtime "PYTHON|3.9"

if %ERRORLEVEL% NEQ 0 (
    echo Deployment failed with exit code %ERRORLEVEL%
    exit /b %ERRORLEVEL%
) else (
    echo Deployment complete.
    exit /b 0
)

endlocal

