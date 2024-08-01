pipeline {
    agent any

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
                    venv\\Scripts\\activate
                    pip install -r requirements.txt
                '''
            }
        }

        stage('Test') {
            steps {
                bat '''
                    venv\\Scripts\\activate
                    pytest tests/
                '''
            }
        }

        stage('Dummy Step') {
            steps {
                echo 'This is a dummy step to ensure pipeline runs'
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
