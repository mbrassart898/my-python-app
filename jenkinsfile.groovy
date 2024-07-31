pipeline {
    agent any

    environment {
        PYTHON_ENV = 'venv'  // Virtual environment name
        AZURE_CREDENTIALS = credentials('azure-service-principal') // Jenkins credentials ID for Azure Service Principal
        AZURE_APP_NAME = 'your-app-name'  // Name of your Azure Web App
        AZURE_RESOURCE_GROUP = 'your-resource-group'  // Name of your Azure Resource Group
        AZURE_LOCATION = 'your-location'  // Location of your Azure resources
    }

    stages {
        stage('Checkout') {
            steps {
                git 'https://your-repository-url.git'
            }
        }

        stage('Setup') {
            steps {
                sh '''
                    python3 -m venv ${PYTHON_ENV}
                    source ${PYTHON_ENV}/bin/activate
                    pip install -r requirements.txt
                '''
            }
        }

        stage('Test') {
            steps {
                sh '''
                    source ${PYTHON_ENV}/bin/activate
                    pytest tests/
                '''
            }
        }

        stage('Deploy') {
            when {
                branch 'main'
                expression {
                    return currentBuild.result == null || currentBuild.result == 'SUCCESS'
                }
            }
            steps {
                script {
                    sh '''
                        az login --service-principal -u ${AZURE_CREDENTIALS_USR} -p ${AZURE_CREDENTIALS_PSW} --tenant ${AZURE_CREDENTIALS_TEN}
                    '''
                    sh '''
                        source ${PYTHON_ENV}/bin/activate
                        ./deploy.sh
                    '''
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
