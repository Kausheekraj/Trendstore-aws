      
#!/usr/bin/env bash
set -e
base_image="kausheekraj/trendstore-nginx"

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    b|build) mode='build' ;;
    p|push)  mode='push' ;;
  esac
  shift
done

date_tag=$(date +'%Y%m%d-%H%M')
date_image="$base_image:$date_tag"

case "$mode" in
  build)
    echo "Building new app image"
    docker compose build --no-cache
    ;;
  push)
    echo "Pushing image"
    docker tag "$base_image:latest" "$date_image"
    docker push "$date_image"
    docker push "$base_image:latest"
    ;;
esac
