#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_COMPOSE_FILE="$ROOT_DIR/compose.yaml"

export WWWGROUP=${WWWGROUP:-$(id -g)}
export WWWUSER=${WWWUSER:-$UID}

usage() {
    cat <<'EOF'
Usage:
  sail [compose-subcommand] [args...]
  sail <app> <command> [args...]

Apps:
  service-booking
  only-client-crm

Examples:
  sail up -d
  sail down
  sail service-booking composer install
  sail only-client-crm artisan migrate
EOF
}

detect_compose() {
    if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
        COMPOSE_BIN=("docker" "compose")
    elif command -v docker-compose >/dev/null 2>&1; then
        COMPOSE_BIN=("docker-compose")
    else
        echo "Error: neither 'docker compose' nor 'docker-compose' is available." >&2
        exit 1
    fi
}

run_compose() {
    "${COMPOSE_BIN[@]}" -f "$ROOT_COMPOSE_FILE" "$@"
}

has_build_flag() {
    for arg in "$@"; do
        case "$arg" in
            --build|--build=*) return 0 ;;
        esac
    done
    return 1
}

resolve_app() {
    local app_key="$1"
    case "$app_key" in
        service-booking)
            APP_SERVICE="service_booking.test"
            APP_WORKDIR="/var/www/html/service-booking"
            ;;
        only-client-crm)
            APP_SERVICE="only_client_crm.test"
            APP_WORKDIR="/var/www/html/only-client-crm"
            ;;
        *)
            APP_SERVICE=""
            APP_WORKDIR=""
            ;;
    esac
}

if [[ $# -eq 0 ]]; then
    usage
    exit 0
fi

case "${1:-}" in
    -h|--help|help)
        usage
        exit 0
        ;;
esac

detect_compose

first_arg="$1"
resolve_app "$first_arg"

if [[ -n "${APP_SERVICE:-}" ]]; then
    shift
    app_cmd="${1:-shell}"
    [[ $# -gt 0 ]] && shift

    case "$app_cmd" in
        up)
            if has_build_flag "$@"; then
                run_compose up "$@" "$APP_SERVICE"
            else
                run_compose up "$@" --build "$APP_SERVICE"
            fi
            ;;
        composer)
            run_compose exec -w "$APP_WORKDIR" "$APP_SERVICE" composer "$@"
            ;;
        artisan|art|a)
            run_compose exec -w "$APP_WORKDIR" "$APP_SERVICE" php artisan "$@"
            ;;
        php|npm|npx|pnpm|pnpx|yarn|bun|bunx|node)
            run_compose exec -w "$APP_WORKDIR" "$APP_SERVICE" "$app_cmd" "$@"
            ;;
        run)
            run_compose exec -w "$APP_WORKDIR" "$APP_SERVICE" "$@"
            ;;
        shell|bash)
            run_compose exec -w "$APP_WORKDIR" "$APP_SERVICE" bash "$@"
            ;;
        root-shell|root-bash)
            run_compose exec -u root -w "$APP_WORKDIR" "$APP_SERVICE" bash "$@"
            ;;
        *)
            run_compose exec -w "$APP_WORKDIR" "$APP_SERVICE" "$app_cmd" "$@"
            ;;
    esac
    exit 0
fi

global_cmd="$1"
shift

if [[ "$global_cmd" == "up" ]]; then
    if has_build_flag "$@"; then
        run_compose up "$@"
    else
        run_compose up "$@" --build
    fi
else
    run_compose "$global_cmd" "$@"
fi