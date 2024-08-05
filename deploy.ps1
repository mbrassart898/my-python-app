# Define variables
$RESOURCE_GROUP = 'mbcicd'
$PLAN_NAME = 'mb-service-plan'
$WEBAPP_NAME = 'mb-app'
$LOCATION = 'South Central US'
$RUNTIME = 'PYTHON:3.11'

# Check if the resource group exists
try {
    $resourceGroup = az group show --name $RESOURCE_GROUP --query "name" -o tsv
    if ($resourceGroup) {
        Write-Output "*** Resource group exists."
    } else {
        Write-Output "*** Resource group does not exist."
        # Create the resource group if it doesn't exist
        az group create --name $RESOURCE_GROUP --location $LOCATION
    }
} catch {
    Write-Output "*** Resource group does not exist."
    # Create the resource group if it doesn't exist
    az group create --name $RESOURCE_GROUP --location $LOCATION
}

# Check if the service plan exists
try {
    $servicePlanName = az appservice plan show --name $PLAN_NAME --resource-group $RESOURCE_GROUP --query "name" -o tsv
    if ($servicePlanName) {
        Write-Output "*** Service plan exists."
    } else {
        Write-Output "*** Service plan does not exist."
        # Create the app service plan if it doesn't exist
        az appservice plan create --name $PLAN_NAME --resource-group $RESOURCE_GROUP --location "$LOCATION" --sku B1 --is-linux
    }
} catch {
    Write-Output "*** Service plan does not exist."
    # Create the app service plan if it doesn't exist
    az appservice plan create --name $PLAN_NAME --resource-group $RESOURCE_GROUP --location "$LOCATION" --sku B1 --is-linux
}

# Check if the web app exists
az webapp create --resource-group $RESOURCE_GROUP --plan $PLAN_NAME --name $WEBAPP_NAME

try {
    $webAppName = az webapp show --name $WEBAPP_NAME --resource-group $RESOURCE_GROUP --query "name" -o tsv
    if ($webAppName) {
        Write-Output "*** Web app exists."
    } else {
        Write-Output "*** Web app does not exist."
        # Create the web app if it doesn't exist
        az webapp create --name $WEBAPP_NAME --resource-group $RESOURCE_GROUP --plan $PLAN_NAME --runtime $RUNTIME --location $LOCATION
    }
} catch {
    Write-Output "*** Web app does not exist."
    # Create the web app if it doesn't exist
    az webapp create --name $WEBAPP_NAME --resource-group $RESOURCE_GROUP --plan $PLAN_NAME --runtime $RUNTIME --location $LOCATION
}

# Deploy the app
Write-Output "Deploying the web app..."
az webapp up --name $WEBAPP_NAME --resource-group $RESOURCE_GROUP --runtime $RUNTIME
if ($LASTEXITCODE -ne 0) {
    Write-Output "Deployment failed with exit code $LASTEXITCODE."
    exit $LASTEXITCODE
} else {
    Write-Output "Deployment completed successfully."
    exit 0
}
