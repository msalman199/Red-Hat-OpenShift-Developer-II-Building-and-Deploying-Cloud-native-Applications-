#!/bin/bash
set -u

log() {
    mkdir -p logs
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ROLLBACK: $1" | tee -a logs/rollback.log
}

get_last_successful_version() {
    if [ -f "logs/successful_deployments.log" ]; then
        tail -n 1 logs/successful_deployments.log
    else
        echo ""
    fi
}

main() {
    local target_version=${1:-}

    if [ "$target_version" = "--help" ] || [ "$target_version" = "-h" ]; then
        echo "Usage: $0 [version]"
        echo "If no version is given, rolls back to the last successful version."
        exit 0
    fi

    if [ -z "$target_version" ]; then
        target_version=$(get_last_successful_version)
        if [ -z "$target_version" ]; then
            log "No successful deployment recorded. Cannot roll back."
            exit 1
        fi
        log "No version specified, rolling back to last successful version: ${target_version}"
    fi

    log "=== Starting rollback to version ${target_version} ==="
    if ./scripts/deploy.sh "$target_version" false; then
        log "=== Rollback completed successfully ==="
        exit 0
    else
        log "=== Rollback failed ==="
        exit 1
    fi
}

main "$@"
