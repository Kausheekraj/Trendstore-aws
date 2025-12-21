pipeline {
    agent any
    environment {
        SCRIPT_DIR = "operation/scripts"
        DOCKER_CREDS = "docker_pat"
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
           docker.withRegistry('https://index.docker.io/v1/', DOCKER_CREDS) 

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
                 kubectl port-forward deployment/trendstore 3000:3000 >/tmp/pf.log 2>&1 &
                  PF_PID=\$!

                sleep 10
                kubectl get pods 
                kubectl get deploy
                kubectl get svc
                kubectl get hpa
                curl -I http://localhost:3000 || true
                kill \$PF_PID
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

