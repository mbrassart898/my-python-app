pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/mbrassart898/my-python-app'
            }
        }

        stage('Dummy Step') {
            steps {
                sh 'echo "This is a dummy step to ensure pipeline runs"'
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
