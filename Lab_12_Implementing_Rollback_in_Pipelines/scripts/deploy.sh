#!/bin/bash
set -u

IMAGE_NAME="pipeline-app"
CONTAINER_NAME="pipeline-app-container"
PORT=5000
HEALTH_CHECK_URL="http://localhost:${PORT}/health"
MAX_RETRIES=10
RETRY_INTERVAL=1

log() {
    mkdir -p logs
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a logs/deployment.log
}

health_check() {
    local retries=0
    while [ $retries -lt $MAX_RETRIES ]; do
        if curl -s -f "$HEALTH_CHECK_URL" > /dev/null 2>&1; then
            return 0
        fi
        retries=$((retries + 1))
        sleep $RETRY_INTERVAL
    done
    return 1
}

cleanup_container() {
    docker stop "$CONTAINER_NAME" > /dev/null 2>&1 || true
    docker rm "$CONTAINER_NAME" > /dev/null 2>&1 || true
}

deploy() {
    local version=$1
    local fail_health=${2:-false}
    local image_tag="${IMAGE_NAME}:${version}"

    if ! docker images --format "{{.Repository}}:{{.Tag}}" | grep -q "^${image_tag}$"; then
        log "Error: image ${image_tag} not found. Build it first."
        return 1
    fi

    cleanup_container

    log "Starting container for version ${version} (simulate_failure=${fail_health})"
    docker run -d \
        --name "$CONTAINER_NAME" \
        -p "${PORT}:5000" \
        -e APP_VERSION="$version" \
        -e FAIL_HEALTH="$fail_health" \
        "$image_tag" > /dev/null

    sleep 2

    if health_check; then
        log "Deployment of version ${version} succeeded"
        echo "$version" >> logs/successful_deployments.log
        return 0
    else
        log "Deployment of version ${version} failed health check"
        return 1
    fi
}

main() {
    local version=${1:-}
    local fail_health=${2:-false}

    if [ -z "$version" ] || [ "$version" = "--help" ] || [ "$version" = "-h" ]; then
        echo "Usage: $0 <version> [fail_health:true|false]"
        exit 0
    fi

    log "=== Starting deployment of version ${version} ==="
    if deploy "$version" "$fail_health"; then
        log "=== Deployment completed successfully ==="
        exit 0
    else
        log "=== Deployment failed ==="
        exit 1
    fi
}

main "$@"
