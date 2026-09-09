#!/bin/bash
set -u

log() {
    mkdir -p logs
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] PIPELINE: $1" | tee -a logs/pipeline.log
}

build_stage() {
    local version=$1
    log "=== BUILD STAGE: version ${version} ==="
    docker build -t "pipeline-app:${version}" --build-arg APP_VERSION="$version" . >> logs/pipeline.log 2>&1
}

deploy_stage() {
    local version=$1
    local fail_health=$2
    log "=== DEPLOY STAGE: version ${version} ==="
    ./scripts/deploy.sh "$version" "$fail_health"
}

rollback_stage() {
    log "=== ROLLBACK STAGE ==="
    ./scripts/rollback.sh
}

main() {
    local version=${1:-}
    local fail_health=${2:-false}

    if [ -z "$version" ] || [ "$version" = "--help" ] || [ "$version" = "-h" ]; then
        echo "Usage: $0 <version> [fail_health:true|false]"
        exit 0
    fi

    mkdir -p logs
    log "=== STARTING PIPELINE: version=${version} fail_health=${fail_health} ==="

    if ! build_stage "$version"; then
        log "Pipeline failed at build stage"
        exit 1
    fi

    if deploy_stage "$version" "$fail_health"; then
        log "=== PIPELINE COMPLETED SUCCESSFULLY ==="
        exit 0
    fi

    log "Deploy stage failed, initiating automatic rollback"
    if rollback_stage; then
        log "=== PIPELINE COMPLETED WITH ROLLBACK ==="
        exit 0
    else
        log "=== PIPELINE FAILED, ROLLBACK ALSO FAILED ==="
        exit 1
    fi
}

main "$@"
