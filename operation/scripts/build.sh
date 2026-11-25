      
#!/usr/bin/env bash
set -e
base_image="kausheekraj/trendstore-nginx"
mode=""
# parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    b|build) mode='build' ;;
    p|push)  mode='push' ;;
  esac
  shift
done

date_tag=$(date +'%y%m%d-%H%M')
date_image="$base_image:$date_tag"

case "$mode" in
  build)
    echo "building new app image"
    docker compose build --no-cache
    minikube image load "$base_image":latest
    ;;
  push)
    echo "pushing image"
    docker tag "$base_image:latest" "$date_image"
    docker push "$date_image"
    docker push "$base_image:latest"
    ;;
esac
exit 0
