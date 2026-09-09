#!/bin/bash
set -u

IMAGE_NAME="pipeline-app"
BLUE_CONTAINER="pipeline-app-blue"
GREEN_CONTAINER="pipeline-app-green"
BLUE_PORT=5001
GREEN_PORT=5002
ACTIVE_PORT=5000
PROXY_CONTAINER="pipeline-app-proxy"
HEALTH_CHECK_RETRIES=10
STATE_FILE="logs/active_environment.txt"

log() {
    mkdir -p logs
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] BLUE-GREEN: $1" | tee -a logs/blue_green.log
}

get_active_environment() {
    if [ -f "$STATE_FILE" ]; then
        cat "$STATE_FILE"
    else
        echo "none"
    fi
}

set_active_environment() {
    mkdir -p logs
    echo "$1" > "$STATE_FILE"
}

get_inactive_environment() {
    local active
    active=$(get_active_environment)
    if [ "$active" = "blue" ]; then
        echo "green"
    else
        echo "blue"
    fi
}

health_check_port() {
    local port=$1
    local retries=0
    while [ $retries -lt $HEALTH_CHECK_RETRIES ]; do
        if curl -s -f "http://localhost:${port}/health" > /dev/null 2>&1; then
            return 0
        fi
        retries=$((retries + 1))
        sleep 1
    done
    return 1
}

deploy_to_inactive() {
    local version=$1
    local fail_health=${2:-false}
    local inactive_env
    inactive_env=$(get_inactive_environment)
    local container_name port

    if [ "$inactive_env" = "blue" ]; then
        container_name=$BLUE_CONTAINER
        port=$BLUE_PORT
    else
        container_name=$GREEN_CONTAINER
        port=$GREEN_PORT
    fi

    log "Deploying version ${version} to ${inactive_env} environment on port ${port}"

    docker stop "$container_name" > /dev/null 2>&1 || true
    docker rm "$container_name" > /dev/null 2>&1 || true

    docker run -d \
        --name "$container_name" \
        -p "${port}:5000" \
        -e APP_VERSION="$version" \
        -e FAIL_HEALTH="$fail_health" \
        "${IMAGE_NAME}:${version}" > /dev/null

    if health_check_port "$port"; then
        log "Health check passed for ${inactive_env} environment"
        echo "$inactive_env"
        return 0
    else
        log "Health check failed for ${inactive_env} environment, leaving traffic unchanged"
        return 1
    fi
}

switch_traffic() {
    local target_env=$1
    local target_port

    if [ "$target_env" = "blue" ]; then
        target_port=$BLUE_PORT
    else
        target_port=$GREEN_PORT
    fi

    log "Switching live traffic on port ${ACTIVE_PORT} to ${target_env} (container port ${target_port})"

    docker stop "$PROXY_CONTAINER" > /dev/null 2>&1 || true
    docker rm "$PROXY_CONTAINER" > /dev/null 2>&1 || true

    docker run -d \
        --name "$PROXY_CONTAINER" \
        -p "${ACTIVE_PORT}:80" \
        -e TARGET_HOST=host.docker.internal \
        -e TARGET_PORT="$target_port" \
        nginx:alpine > /dev/null 2>&1 || true

    set_active_environment "$target_env"
    log "Traffic switch recorded: active environment is now ${target_env}"
}

rollback_traffic() {
    local current
    current=$(get_active_environment)
    local previous

    if [ "$current" = "blue" ]; then
        previous="green"
    else
        previous="blue"
    fi

    log "Rolling back traffic from ${current} to ${previous}"

    local previous_port
    if [ "$previous" = "blue" ]; then
        previous_port=$BLUE_PORT
    else
        previous_port=$GREEN_PORT
    fi

    if health_check_port "$previous_port"; then
        set_active_environment "$previous"
        log "Rollback successful: active environment is now ${previous}"
        return 0
    else
        log "Rollback failed: ${previous} environment is not healthy"
        return 1
    fi
}

main() {
    local action=${1:-}
    local version=${2:-}
    local fail_health=${3:-false}

    case "$action" in
        deploy)
            if [ -z "$version" ]; then
                echo "Usage: $0 deploy <version> [fail_health:true|false]"
                exit 1
            fi
            local new_env
            if new_env=$(deploy_to_inactive "$version" "$fail_health"); then
                switch_traffic "$new_env"
                log "=== BLUE-GREEN DEPLOYMENT COMPLETED: active environment ${new_env} ==="
                exit 0
            else
                log "=== BLUE-GREEN DEPLOYMENT FAILED: traffic remains on $(get_active_environment) ==="
                exit 1
            fi
            ;;
        rollback)
            if rollback_traffic; then
                log "=== ROLLBACK COMPLETED ==="
                exit 0
            else
                log "=== ROLLBACK FAILED ==="
                exit 1
            fi
            ;;
        status)
            echo "Active environment: $(get_active_environment)"
            ;;
        *)
            echo "Usage: $0 {deploy|rollback|status} [version] [fail_health]"
            exit 1
            ;;
    esac
}

main "$@"
