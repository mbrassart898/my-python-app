#!/bin/bash

echo "Deploying to Azure Web App..."
az webapp up --name your-azure-app-url --runtime "PYTHON|3.9"
echo "Deployment complete."
