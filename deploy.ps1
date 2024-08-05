# Define variables
$RESOURCE_GROUP = "mbcicd"
$PLAN_NAME = "mb-service-plan"
$WEBAPP_NAME = "mb-app"
$LOCATION = "South Central US"
$RUNTIME = "PYTHON|3.11"
$OS_TYPE = "linux"

Write-Host "Deploying the web app..."
$deploy = az webapp up --name $WEBAPP_NAME --resource-group $RESOURCE_GROUP --runtime $RUNTIME 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Deployment failed with exit code $LASTEXITCODE. Check details below:"
    Write-Host $deploy
    exit $LASTEXITCODE
} else {
    Write-Host "Deployment completed successfully."
    exit 0
}
