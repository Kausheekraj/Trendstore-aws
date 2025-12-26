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
               script{
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
                    minikube image load kausheekraj/trendstore-nginx:latest
                """
            }
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
                
                sh """
                  kubectl get nodes -o wide
                  kubectl get pods -n default -l app=trendstore
                  kubectl get hpa trendstore-hpa
        
                  kubectl port-forward -n monitoring svc/monitoring-kube-prometheus-prometheus 9090:9090 >/tmp/prom.log 2>&1 &
                   sleep 5
                   curl -s "http://localhost:9090/api/v1/query?query=up{job=~'kubelet|kube-state-metrics'}" | grep '"value"' && echo "✅ Prometheus healthy"
                """
            }
        }
        stage('Grafana dashboard') {
          steps {
            sh '''
          kkubectl port-forward -n monitoring svc/monitoring-grafana 3000:80
            sleep 5
            curl -s "http://localhost:3000/d/6417/k8s-cluster?orgId=1&from=now-1h&to=now&var-ds_prometheus=Prometheus&var-cluster=&var-namespace=default&var-job=&var-pod=trendstore" > /dev/null
            echo "✅ Grafana dashboard accessible at port-forward:3000/d/6417"
            '''
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

