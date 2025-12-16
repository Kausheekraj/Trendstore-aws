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
            sh """
                ${SCRIPT_DIR}/compose.sh -p
                 minikube image load kausheekraj/trendstore-nginx:latest
            """
        }
    }



        stage('Deploy Container') {
            steps {
                sh "${SCRIPT_DIR}/compose.sh -d"
            }
        }

        stage('Health Check') {
            steps {
                
                sh """
                sleep 10
                kubectl get pods 
                kubectl get deploy
                kubectl get svc
                kubectl get hpa
                curl -I http://localhost:3000 || true
                """
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

