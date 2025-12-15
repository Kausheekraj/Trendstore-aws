#!/usr/bin/env bash
set -e
if [[ "${1}" == 'p' ]]; then
     docker compose push
   else
echo  "Building custom Docker Nginx image"
docker compose build --no-cache

fi
