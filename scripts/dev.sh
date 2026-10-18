#!/bin/bash

set -euo pipefail

readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly NC='\033[0m'
readonly SERVICE_NAME="iponce-blog"

print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker não está instalado."
        exit 1
    fi

    if ! docker compose version &> /dev/null; then
        print_error "Docker Compose não está disponível."
        exit 1
    fi
}

start_dev() {
    print_message "Iniciando ambiente..."
    docker compose up --build -d
    print_message "Servidor em: http://localhost:1313"
}

stop_dev() {
    print_message "Parando ambiente..."
    docker compose down
}

rebuild() {
    print_message "Rebuildando..."
    docker compose down
    docker compose build --no-cache
    docker compose up -d
}

logs() {
    docker compose logs -f
}

exec_command() {
    if [ -z "${1:-}" ]; then
        print_error "Comando não especificado"
        exit 1
    fi

    print_message "Executando: $1"
    docker compose exec "$SERVICE_NAME" "$@"
}

generate_index() {
    print_message "Gerando índice..."
    docker compose exec "$SERVICE_NAME" ruby scripts/generate_index.rb
}

show_help() {
    echo "Comandos:"
    echo "  start          - Inicia o ambiente"
    echo "  stop           - Para o ambiente"
    echo "  restart        - Reinicia o ambiente"
    echo "  rebuild        - Rebuilda a imagem"
    echo "  logs           - Mostra os logs"
    echo "  exec <cmd>     - Executa comando no container"
    echo "  generate-index - Gera o índice de posts"
    echo "  new-post <title> - Cria um novo post"
    echo "  help           - Mostra esta ajuda"
}

main() {
    case "${1:-help}" in
        start)
            check_docker
            start_dev
            ;;
        stop)
            check_docker
            stop_dev
            ;;
        restart)
            check_docker
            stop_dev
            start_dev
            ;;
        rebuild)
            check_docker
            rebuild
            ;;
        logs)
            check_docker
            logs
            ;;
        exec)
            check_docker
            shift
            exec_command "$@"
            ;;
        generate-index)
            check_docker
            generate_index
            ;;
        new-post)
            shift
            ruby scripts/new_post.rb "$@"
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            print_error "Comando desconhecido: $1"
            show_help
            exit 1
            ;;
    esac
}

main "$@"
