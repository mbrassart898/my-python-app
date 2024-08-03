@echo off

echo Deploying to Azure Web App...
az webapp up --name your-azure-app-url --runtime "PYTHON|3.9"

if %ERRORLEVEL% NEQ 0 (
    echo Deployment failed with exit code %ERRORLEVEL%
    exit /b %ERRORLEVEL%
) else (
    echo Deployment complete.
    exit /b 0
)
