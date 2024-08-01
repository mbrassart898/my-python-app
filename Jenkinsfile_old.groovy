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
                bat '''
                    python -m venv venv
                    call venv\\Scripts\\activate
                    pip install -r requirements.txt
                '''
            }
        }

        stage('Test') {
            steps {
                bat '''
                    call venv\\Scripts\\activate
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
                bat '''
                    az login --service-principal -u ${AZURE_CREDENTIALS_USR} -p ${AZURE_CREDENTIALS_PSW} --tenant ${AZURE_CREDENTIALS_TEN}
                    call venv\\Scripts\\activate
                    ./deploy.sh
                '''
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
