#### 🛍️ Trendstore – CI/CD Deployment on AWS EKS

### 📌 Overview

Trendstore is a frontend-only web application served using Nginx, containerized with Docker, deployed on AWS EKS, and fully automated using a Jenkins CI/CD pipeline.

This project demonstrates a realistic, end-to-end DevOps workflow:

🐳 Containerizing a frontend application

🏗️ Provisioning AWS infrastructure using Terraform

☸️ Deploying and scaling workloads on Kubernetes (EKS)

🔁 Automating build & deployment with Jenkins

📊 Monitoring cluster and workloads using Prometheus & Grafana

🔐 Secure GitHub → Jenkins integration using Cloudflared

High-level flow:

GitHub push → Jenkins pipeline → Docker build & push → EKS deploy → HPA scaling → Monitoring dashboards

---

# 📁 Repository Structure

application/
└─ dist/ # Built frontend assets

operation/
├─ Docker/ # Dockerfile & docker-compose
├─ k8s/ # Deployment, Service, HPA
├─ scripts/ # Build, deploy, cleanup logic
└─ infra/terraform/ # AWS VPC + EKS IaC

Jenkinsfile # CI/CD pipeline

This separation mirrors real-world production projects:

Application artifacts

Infrastructure as Code

Operational automation

---

### 🧱 Architecture Summary

## 🔁 CI / Source Control

GitHub hosts:

Application code

Infrastructure (Terraform)

Jenkins pipeline (Jenkinsfile)

Jenkins pipeline is triggered via GitHub Webhooks

Cloudflared securely exposes a local/private Jenkins instance without opening inbound ports

---

## 🐳 Containerization & Registry

Application is a static frontend served by Nginx

Docker image is built from application/dist

Docker Compose ensures:

Local testing

CI consistency

Image is pushed to Docker Hub
📦 kausheekraj/trendstore-nginx

🏗️ Infrastructure (Terraform on AWS)

Provisioned entirely using Terraform:

Custom VPC with public & private subnets

Internet Gateway + NAT Gateway

IAM roles for:

EKS control plane

Worker nodes

AWS EKS cluster (trendstore-eks)

Managed node group (cost-efficient instance types)

---

✅ Terraform ensures the infrastructure is reproducible, version-controlled, and auditable.

### ☸️ Kubernetes Deployment

## 📦 Deployment

Runs an Nginx container serving static frontend assets

Resource requests & limits are defined to enable autoscaling:

Resource Request Limit
CPU 100m 250m
Memory 128Mi 256Mi

## 🌐 Service (Updated Design)

The application is exposed using a LoadBalancer service.

Why LoadBalancer instead of NodePort?

Automatically provisions an AWS Elastic Load Balancer

Provides a public DNS endpoint

No manual node IP or port handling

More realistic for production-style EKS deployments

Simplifies access during demo and submission

📈 Horizontal Pod Autoscaler (HPA)

Scales pods from 1 → 5 replicas

Triggered at 60% CPU utilization

Verified using k6 load testing

---

## 🔁 CI/CD Pipeline (Jenkins)

# 🧭 Pipeline Flow

Developer
|
| git push
v
GitHub Repository
|
| (Webhook via Cloudflared)
v
Jenkins Pipeline
|
|-- Build Docker Image
|-- Push Image to Docker Hub
|-- Configure kubeconfig (EKS)
|-- Deploy to Kubernetes
|-- Install / Verify Monitoring
v
AWS EKS Cluster
|
|-- trendstore pods (Nginx)
|-- HPA auto-scaling
|-- Prometheus & Grafana dashboards

### 🤖 Why Jenkins?

Clear, stage-based declarative pipelines

Strong Docker & Kubernetes integration

Widely used in real-world production environments

### 🧪 Pipeline Stages (Summary)

Checkout
Pull source code from GitHub

Prepare Scripts
Ensure operational scripts are executable

Build Image
Build Docker image using Docker Compose

Push Image

Authenticate to Docker Hub

Push latest and versioned images

Configure Kubeconfig

Inject AWS credentials

Run aws eks update-kubeconfig

Deploy to EKS
Apply Deployment, Service, and HPA manifests

Monitoring Setup
Install / upgrade kube-prometheus-stack via Helm

Health Checks
Validate nodes, pods, and HPA behavior

Grafana Verification
Confirm dashboards and metrics visibility

---

### 📊 Monitoring & Observability

## 🔍 Stack (Installed via Helm)

Prometheus

Grafana

kube-state-metrics

node-exporter

Alertmanager

# 💡 Why kube-prometheus-stack?

Industry-standard Kubernetes monitoring bundle

Minimal manual configuration

Preconfigured dashboards

Ideal for production-like observability demos

# 🔐 Access Method

Prometheus & Grafana accessed via kubectl port-forward

Avoids public exposure of monitoring endpoints

Common and secure operational practice

🎯 Key Design Decisions (Why This Matters)

Nginx + static assets → lightweight, fast, production-standard

Docker everywhere → consistency across local, CI, and Kubernetes

Terraform for EKS → reproducible infrastructure

HPA-enabled workloads → cloud-native scaling

Jenkins pipelines → full CI/CD visibility

Helm for monitoring → avoids YAML sprawl

Cloudflared → secure webhooks without opening ports

---

### ✅ Outcome

This project delivers a complete DevOps lifecycle:

Automated builds and deployments

Kubernetes-based autoscaling

Production-style monitoring

Secure CI/CD integration

Cost-conscious design suitable for labs and demos

The focus is on clarity, realism, and operational correctness over unnecessary complexity.
