pipeline {
    agent any

    environment {
        PATH = "C:\\Program Files\\Common Files\\Oracle\\Java\\javapath;C:\\Program Files (x86)\\Common Files\\Oracle\\Java\\javapath;C:\\ProgramData\\Oracle\\Java\\javapath;C:\\WINDOWS\\System32;C:\\WINDOWS;C:\\WINDOWS\\System32\\Wbem;C:\\WINDOWS\\System32\\WindowsPowerShell\\v1.0\\;C:\\Program Files (x86)\\Bitvise SSH Client;C:\\WINDOWS\\System32\\OpenSSH\\;C:\\Program Files\\Git\\cmd;C:\\Program Files\\Git\\bin;C:\\Windows\\System32;C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe;C:\\Users\\michel\\AppData\\Local\\Microsoft\\WindowsApps;C:\\Program Files\\New Relic\\New Relic CLI\\;C:\\Users\\michel\\AppData\\Local\\Programs\\Microsoft VS Code\\bin;C:\\Program Files\\Microsoft SDKs\\Azure\\CLI2\\wbin"
        AZURE_CREDENTIALS = credentials('jenkins-service-principal')
        AZURE_APP_NAME = 'app.py'
        AZURE_RESOURCE_GROUP = 'jenkins_test'
        AZURE_LOCATION = 'East US'
        AZURE_TENANT = '6e360dff-1d95-4b19-9f75-c368c059e950'
        PYTHONPATH = "."
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
                script {
                    env.BRANCH_NAME = bat(script: 'git rev-parse --abbrev-ref HEAD', returnStdout: true).trim()
                }
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

        stage('Debug Info') {
            steps {
                script {
                    echo "Current Branch: ${env.BRANCH_NAME}"
                    echo "Current Build Result: ${currentBuild.result}"
                }
            }
        }

        stage('Deploy') {
            when {
                allOf {
                    expression { env.BRANCH_NAME ==~ /(origin\/)?master/ }
                    expression { currentBuild.result == null || currentBuild.result == 'SUCCESS' }
                }
            }
            steps {
                bat '''
                    az login --service-principal -u %AZURE_CREDENTIALS_USR% -p %AZURE_CREDENTIALS_PSW% --tenant %AZURE_TENANT%
                    call venv\\Scripts\\activate
                    call deploy.bat
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
