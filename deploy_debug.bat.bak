@echo off
echo "Starting deployment debugging..."

:: Environment Diagnostics
echo "Environment Diagnostics:"
echo %PATH%
where cmd
python --version
pip --version
az --version
powershell -Command "Write-Output PowerShell command is working!"

:: Activate virtual environment
call venv\Scripts\activate

:: Deploy to Azure
az login --service-principal -u 50734d15-045b-42ec-a91e-5674d6fcdb5c -p VAg8Q~n5geP_BgBbAWTI9F.pUUXc6GV0ny0xAcL- --tenant 6e360dff-1d95-4b19-9f75-c368c059e950
az webapp up --name your-azure-app-url --runtime "PYTHON|3.9"
echo "Deployment complete."

pause
