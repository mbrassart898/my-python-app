pipeline {
    agent any

    environment {
        PATH = "C:\\Windows\\System32;C:\\Windows;C:\\Program Files\\Common Files\\Oracle\\Java\\javapath;C:\\Program Files (x86)\\Common Files\\Oracle\\Java\\javapath;C:\\ProgramData\\Oracle\\Java\\javapath;C:\\WINDOWS\\System32\\Wbem;C:\\WINDOWS\\System32\\WindowsPowerShell\\v1.0\\;C:\\Program Files (x86)\\Bitvise SSH Client;C:\\WINDOWS\\System32\\OpenSSH\\;C:\\Program Files\\Git\\cmd;C:\\Program Files\\Git\\bin;C:\\Users\\michel\\AppData\\Local\\Microsoft\\WindowsApps;C:\\Program Files\\New Relic\\New Relic CLI\\;C:\\Users\\michel\\AppData\\Local\\Programs\\Microsoft VS Code\\bin;C:\\Program Files\\Microsoft SDKs\\Azure\\CLI2\\wbin"
        AZURE_CREDENTIALS = credentials('service-principal')
        AZURE_APP_NAME = 'mb-app'
        AZURE_RESOURCE_GROUP = 'mbcicd'
        AZURE_LOCATION = 'South Central US'
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

                    echo 'Executing deploy.ps1...'
                    def deployStatus = powershell(script: '${workspace}\\deploy.ps1', returnStatus: true)
                    if (deployStatus != 0) {
                        echo 'Deployment failed with exit code ${deployStatus}'
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
