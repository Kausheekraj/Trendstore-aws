#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OPERATION_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

DOCKER_DIR="$OPERATION_ROOT/Docker"
SCRIPTS_DIR="$OPERATION_ROOT/scripts"
K8S_DIR="$OPERATION_ROOT/k8s"

usage() {
  cat <<EOF
[Usage]: $0 [-b] [-d] [-s] [-r] [-p] [-h]
   ==============================
    -b   Build image
    -d   Deploy container
    -s   Stop container
    -r   Remove container image
    -p   Push container image
    -h   Show this help
   ==============================
EOF
  exit 1
}

no_opts() {
  echo "Please provide a valid option."
  echo "Try $0 -h or --help for more."
  exit 1
}

# Handle long option --help
for arg in "$@"; do
  [[ "$arg" == "--help" ]] && usage
done

while getopts "pbdsrh" opts; do
  case "$opts" in
    b) (cd "$DOCKER_DIR" && bash "$SCRIPTS_DIR/build.sh" b )  ;;
    p) (cd "$DOCKER_DIR" && bash "$SCRIPTS_DIR/build.sh" p) ;;
    d) (cd "$K8S_DIR" && bash "$SCRIPTS_DIR/deploy.sh") ;;
    s) (cd "$K8S_DIR" && bash "$SCRIPTS_DIR/options.sh" s ) ;;
    r) (cd "$DOCKER_DIR" && bash "$SCRIPTS_DIR/options.sh" r ) ;;
    h) usage ;;
    ?) no_opts ;;
  esac
done

[[ $# -eq 0 ]] && usage
