pipeline {
    agent any

    environment {
        AZURE_CREDENTIALS = credentials('service-principal')
        AZURE_APP_NAME = 'mb-app'
        AZURE_RESOURCE_GROUP = 'jenkins_test'
        AZURE_LOCATION = 'EastUS'
        AZURE_TENANT = '6e360dff-1d95-4b19-9f75-c368c059e950'
        PYTHONPATH = "."
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Environment Diagnostics') {
            steps {
                bat '''
                    echo PATH=%PATH%
                    where cmd
                    python --version
                    pip --version
                    az --version
                    powershell -Command "Write-Output PowerShell command is working!"
                '''
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
                    set PYTHONPATH=.
                    pytest tests/
                '''
            }
        }

        stage('Deploy') {
            steps {
                script {
                    echo 'Starting Azure login...'
                    def loginStatus = bat(script: '''
                        az login --service-principal -u %AZURE_CREDENTIALS_USR% -p %AZURE_CREDENTIALS_PSW% --tenant %AZURE_TENANT%
                    ''', returnStatus: true)
                    if (loginStatus != 0) {
                        error("Azure login failed with exit code ${loginStatus}")
                    } else {
                        echo 'Azure login successful'
                    }

                    echo 'Executing deploy.bat...'
                    def deployStatus = bat(script: '''
                        call deploy.bat
                    ''', returnStatus: true)
                    if (deployStatus != 0) {
                        echo 'Checking logs for more details...'
                        bat '''
                            type check_resource_group.log
                            type create_resource_group.log
                            type check_plan.log
                            type create_plan.log
                            type check_webapp.log
                            type create_webapp.log
                            type deploy.log
                        '''
                        error("Deployment failed with exit code ${deployStatus}")
                    } else {
                        echo 'Deployment script executed successfully'
                    }
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
