#!/usr/bin/env bash
if [[ "${1}" == 'r' ]]; then
  echo "Removing existing Docker Nginx image... "
 docker compose down   --volumes --remove-orphans

else 
echo "[CLEAN] Removing Kubernetes resources..."
kubectl delete -f deployment.yaml || true
kubectl delete -f service.yaml || true
kubectl delete -f hpa.yaml || true
echo "[CLEAN] Done. Everything cleared."
fi
