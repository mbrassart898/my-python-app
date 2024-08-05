# Define variables
$RESOURCE_GROUP = "mbcicd"
$PLAN_NAME = "mb-service-plan"
$WEBAPP_NAME = "mb-app"
$LOCATION = "South Central US"
$RUNTIME = "PYTHON|3.11"
$OS_TYPE = "linux"

Write-Host "Checking if the resource group exists..."
$resourceGroup = az group show --name $RESOURCE_GROUP 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Resource group $RESOURCE_GROUP does not exist. Creating resource group..."
    $createResourceGroup = az group create --name $RESOURCE_GROUP --location $LOCATION 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed to create resource group. Check details below:"
        Write-Host $createResourceGroup
        exit $LASTEXITCODE
    }
}

Write-Host "Checking if the app service plan exists..."
$appServicePlan = az appservice plan show --name $PLAN_NAME --resource-group $RESOURCE_GROUP 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "App service plan $PLAN_NAME does not exist. Creating app service plan..."
    $createPlan = az appservice plan create --name $PLAN_NAME --resource-group $RESOURCE_GROUP --sku B1 --is-linux 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed to create app service plan. Check details below:"
        Write-Host $createPlan
        exit $LASTEXITCODE
    }
}

Write-Host "Checking if the web app exists..."
$webApp = az webapp show --name $WEBAPP_NAME --resource-group $RESOURCE_GROUP 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Web app $WEBAPP_NAME does not exist. Creating web app..."
    $createWebApp = az webapp create --name $WEBAPP_NAME --resource-group $RESOURCE_GROUP --plan $PLAN_NAME --runtime $RUNTIME 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed to create web app. Check details below:"
        Write-Host $createWebApp
        exit $LASTEXITCODE
    }
}

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
