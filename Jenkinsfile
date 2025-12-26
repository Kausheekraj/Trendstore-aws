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

        stage('Build image') {
            steps {
                sh "${SCRIPT_DIR}/compose.sh -b"
            }
        }

        stage('Push Image') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', 'docker_pat') {
                        sh "${SCRIPT_DIR}/compose.sh -p"
                    }
                }
            }
        }

        stage('Configure Kubeconfig for EKS') {
            steps {
                withCredentials([
                    aws(
                        credentialsId: 'aws-creds-id',
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    )
                ]) {
                    sh '''
                      aws eks update-kubeconfig \
                        --name trendstore-eks \
                        --region us-east-2
                    '''
                }
            }
        }

        stage('Deploy Container') {
            steps {
                withCredentials([
                    aws(
                        credentialsId: 'aws-creds-id',
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    )
                ]) {
                    sh "${SCRIPT_DIR}/compose.sh -d"
                }
            }
        }

        stage('Monitoring Setup') {
            steps {
                withCredentials([
                    aws(
                        credentialsId: 'aws-creds-id',
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    )
                ]) {
                    sh '''
                      helm repo add prometheus-community https://prometheus-community.github.io/helm-charts || true
                      helm repo update
                      helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
                        --namespace monitoring --create-namespace
                    '''
                }
            }
        }

        stage('Health Check') {
            steps {
                withCredentials([
                    aws(
                        credentialsId: 'aws-creds-id',
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    )
                ]) {
                    catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                        sh '''
                          kubectl get nodes -o wide
                          kubectl get pods -n default -l app=trendstore
                          kubectl get hpa trendstore-hpa

                          kubectl port-forward -n monitoring svc/monitoring-kube-prometheus-prometheus 9090:9090 >${WORKSPACE}/prom_pf.log 2>&1 &
                          PF_PID=$!
                          sleep 5
                          curl -s "http://localhost:9090/api/v1/query?query=up" || true
                          kill $PF_PID || true
                        '''
                    }
                }
            }
        }

        stage('Grafana Dashboard') {
            steps {
                withCredentials([
                    aws(
                        credentialsId: 'aws-creds-id',
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    )
                ]) {
                    sh '''
                      kubectl port-forward -n monitoring svc/monitoring-grafana 3001:80 > ${WORKSPACE}/grafana_pf.log 2>&1 &
                      GF_PID=$!
                      sleep 5
                      curl -s http://localhost:3000/login >/dev/null || true
                      kill $GF_PID || true
                    '''
                }
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

