pipeline {
    agent any

    environment {
        SCRIPT_DIR = "operation/scripts"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Prepare Scripts') {
            steps {
                sh "chmod +x ${SCRIPT_DIR}/*.sh"
            }
        }

        stage('Build Image') {
            steps {
                sh "${SCRIPT_DIR}/compose.sh -b"
            }
        }
        stage('Push Image') {
    steps {
        withCredentials([string(credentialsId: 'DOCKERHUB_PAT', variable: 'DOCKERHUB_PAT')]) {
            sh 'echo $DOCKERHUB_PAT | docker login -u kausheekraj --password-stdin && ${SCRIPT_DIR}/compose.sh -p'
        }
      }
   }


        stage('Deploy Container') {
            steps {
                sh "${SCRIPT_DIR}/compose.sh -d"
            }
        }

        stage('Health Check') {
            steps {
                script {
                    sleep 5
                }
                sh "curl -I http://localhost:3000 || true"
            }
        }
    }

    post {
        success {
            echo 'Deployment Successful'
        }
        failure {
            echo 'Pipeline Failed — Check Logs'
        }
    }
}

