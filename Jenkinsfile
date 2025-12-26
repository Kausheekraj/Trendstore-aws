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
                script {
                    sh "chmod +x ${SCRIPT_DIR}/*.sh"
                }
            }
        }

        stage('Build image') {
            steps {
                sh """
                ${SCRIPT_DIR}/compose.sh -b
                """
            }
        }

        stage('Push Image') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', 'docker_pat') {
                        sh """
                        ${SCRIPT_DIR}/compose.sh -p
                        """
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
                sh "${SCRIPT_DIR}/compose.sh -d"
            }
        }

        stage('Monitoring Setup') {
            steps {
                sh """
                helm repo add prometheus-community https://prometheus-community.github.io/helm-charts || true
                helm repo update
                helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
                  --namespace monitoring --create-namespace
                """
            }
        }

        stage('Health Check') {
            steps {
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                    sh """
                    kubectl get nodes -o wide
                    kubectl get pods -n default -l app=trendstore
                    kubectl get hpa trendstore-hpa

                    kubectl port-forward -n monitoring svc/monitoring-kube-prometheus-prometheus 9090:9090 >${WORKSPACE}/prom_pf.log 2>&1 &
                    PF_PID=\$!
                    sleep 5
                    curl -s "http://localhost:9090/api/v1/query?query=up{job=~'kubelet|kube-state-metrics'}" | grep '"value"' || true
                    echo "Prometheus health check stage completed"
                    kill \$PF_PID || true
                    """
                }
            }
        }

        stage('grafana dashboard') {
            steps {
                sh """
                kubectl port-forward -n monitoring svc/monitoring-grafana 3000:80 > ${WORKSPACE}/grafana_pf.log 2>&1 &
                GF_PID=\$!
                sleep 5
                # orgId must have capital I, datasource usually named 'Prometheus' [web:41][web:25]
                curl -s "http://localhost:3000/d/6417/k8s-cluster?orgId=1&from=now-1h&to=now&var-ds_prometheus=Prometheus&var-cluster=&var-namespace=default&var-job=&var-pod=trendstore" >/dev/null || true
                echo "grafana dashboard accessible at port-forward:3000/d/6417"
                kill \$GF_PID || true
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

