#!/usr/bin/env bash
set -e
echo "Stopping any existing containers of this image..."
kubectl delete -f deployment.yaml --ignore-not-found
kubectl delete -f service.yaml   --ignore-not-found  
kubectl delete -f hpa.yaml     --ignore-not-found
echo "Deploying Container..."

kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl apply -f hpa.yaml
