pipeline  {
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
                        az login --service-principal -u $mikebrassart@gmail.com -p $VAg8Q~n5geP_BgBbAWTI9F.pUUXc6GV0ny0xAcL- --tenant $6e360dff-1d95-4b19-9f75-c368c059e950
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
