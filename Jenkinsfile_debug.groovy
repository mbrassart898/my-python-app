pipeline {
    agent any

    stages {
        stage('Dummy Step') {
            steps {
                echo 'This is a dummy step to test cleanWs'
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
