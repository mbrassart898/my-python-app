@echo off
REM Ensure the script fails if any command fails
setlocal enabledelayedexpansion
set errorlevel=0

echo "Deploying to Azure Web App..."
az webapp up --name your-azure-app-url --runtime "PYTHON|3.9"
set errorlevel=%ERRORLEVEL%

if %errorlevel% neq 0 (
    echo "Deployment failed with exit code %errorlevel%"
    exit /b %errorlevel%
) else (
    echo "Deployment complete."
    exit /b 0
)
