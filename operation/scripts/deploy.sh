#!/usr/bin/env bash
set -e
echo "Stopping any existing containers of this image..."
kubectl delete -f deployment.yaml
kubectl delete -f service.yaml
kubectl delete -f hpa.yaml
echo "Deploying Container..."

kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl apply -f hpa.yaml
