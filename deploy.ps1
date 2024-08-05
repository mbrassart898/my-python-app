Write-Output "Starting deployment script..."

$RESOURCE_GROUP = "mbcicd"
$PLAN_NAME = "mb-service-plan"
$WEBAPP_NAME = "mb-app"
$LOCATION = "South Central US"
$RUNTIME = "PYTHON 3.11"
$OS_TYPE = "linux"

Write-Output "Resource group: $RESOURCE_GROUP"
Write-Output "Plan name: $PLAN_NAME"
Write-Output "Webapp name: $WEBAPP_NAME"
Write-Output "Location: $LOCATION"
Write-Output "Runtime: $RUNTIME"
Write-Output "OS type: $OS_TYPE"

Write-Output "Deploying the web app..."
az webapp up --name $WEBAPP_NAME --resource-group $RESOURCE_GROUP --runtime $RUNTIME

if ($LASTEXITCODE -ne 0) {
    Write-Output "Deployment failed with exit code $LASTEXITCODE."
    exit $LASTEXITCODE
} else {
    Write-Output "Deployment completed successfully."
    exit 0
}
