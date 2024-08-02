pipeline {
    agent any

    environment {
        PYTHON_ENV = 'venv'  // Virtual environment name
        AZURE_CREDENTIALS = credentials('jenkins-service-principal') // Jenkins credentials ID for Azure Service Principal
        AZURE_APP_NAME = 'app.py'  // Name of your Azure Web App
        AZURE_RESOURCE_GROUP = 'jenkins_test'  // Name of your Azure Resource Group
        AZURE_LOCATION = 'East US'  // Location of your Azure resources
    }

    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/mbrassart898/my-python-app'
            }
        }

        stage('Setup') {
            steps {
                // Debugging: Print the PATH environment variable
                powershell 'echo $env:PATH'
                
                // Debugging: Verify cmd is accessible
                powershell 'Get-Command cmd'
                
                // Normal setup steps
                powershell '''
                    python --version
                    pip --version
                    python -m venv venv
                    .\\venv\\Scripts\\Activate.ps1
                    pip install -r requirements.txt
                '''
            }
        }

        stage('Test') {
            steps {
                powershell '''
                    .\\venv\\Scripts\\Activate.ps1
                    pytest tests/
                '''
            }
        }

        stage('Dummy Step') {
            steps {
                echo 'This is a dummy step to ensure pipeline runs'
            }
        }

        stage('Deploy') {
            when {
                branch 'master'
                expression {
                    return currentBuild.result == null || currentBuild.result == 'SUCCESS'
                }
            }
            steps {
                script {
                    // Debugging: Print environment variables to verify they are set correctly
                    echo "Azure SP User: ${AZURE_CREDENTIALS_USR}"
                    echo "Azure SP Tenant: ${AZURE_CREDENTIALS_TEN}"

                    // Attempt to login to Azure
                    def loginCommand = """
                        az login --service-principal \
                        -u ${AZURE_CREDENTIALS_USR} \
                        -p ${AZURE_CREDENTIALS_PSW} \
                        --tenant ${AZURE_CREDENTIALS_TEN}
                    """
                    powershell loginCommand

                    // Verify Azure login success
                    powershell 'az account show'

                    // Activate virtual environment and run deployment script
                    powershell '''
                        .\\venv\\Scripts\\Activate.ps1
                        ./deploy.sh
                    '''
                }
            }
        }
    }

    post {
        always {
            script {
                node {
                    cleanWs()
                }
            }
        }
    }
}
