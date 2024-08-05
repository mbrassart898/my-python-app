Write-Output "Starting deployment script..."

$RESOURCE_GROUP = "mbcicd"
$PLAN_NAME = "mb-service-plan"
$WEBAPP_NAME = "mb-app"
$LOCATION = "South Central US"
$RUNTIME = "PYTHON:3.11"
$OS_TYPE = "linux"

Write-Output "Resource group: $RESOURCE_GROUP"
Write-Output "Plan name: $PLAN_NAME"
Write-Output "Webapp name: $WEBAPP_NAME"
Write-Output "Location: $LOCATION"
Write-Output "Runtime: $RUNTIME"
Write-Output "OS type: $OS_TYPE"

# Check if the resource group exist
$resourceGroupExists = (az group exists --name 'mbcicd') -eq 'true'
if ($resourceGroupExists) {
    Write-Output "*** Resource group exists."
} else {
    Write-Output "*** Resource group does not exist."
    # Creating the resource group
    #az group create --name $RESOURCE_GROUP --location "$LOCATION"
}

# Check if the service plan exist
$servicePlanExists = (az appservice plan show --name 'mb-service-plan' --resource-group 'mbcicd' --query "name" -o tsv) -ne ''
if ($servicePlanExists) {
    Write-Output "*** Service plan exists."
} else {
    Write-Output "*** Service plan does not exist."
    # Create the app service plan if it doesn't exist
    # az appservice plan create --name $PLAN_NAME --resource-group $RESOURCE_GROUP --location "$LOCATION" --sku B1 --is-linux
}


# Check if the web app exist
try {
    $webAppName = az webapp show --name 'mb-app' --resource-group 'mbcicd' --query "name" -o tsv
    if ($webAppName) {
        Write-Output "*** Web app exists."
    } else {
        Write-Output "*** Web app does not exist."
        # Create the web app if it doesn't exist
        az webapp create --name 'mb-app' --resource-group 'mbcicd' --plan 'mb-service-plan' --location "$LOCATION" --runtime 'PYTHON:3.11' 
    }
} catch {
    Write-Output "*** Web app does not exist."
    # Create the web app if it doesn't exist
    az webapp create --name 'mb-app' --resource-group 'mbcicd' --plan 'mb-service-plan' --location "$LOCATION" --runtime 'PYTHON:3.11' 
    Write-Output "*** Created Web app."
}

Write-Output "Deploying the web app..."
az webapp up --name $WEBAPP_NAME --resource-group $RESOURCE_GROUP --location "$LOCATION" --runtime $RUNTIME --os-type $OS_TYPE

if ($LASTEXITCODE -ne 0) {
    Write-Output "Deployment failed with exit code $LASTEXITCODE."
    exit $LASTEXITCODE
} else {
    Write-Output "Deployment completed successfully."
    exit 0
}
