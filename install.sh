#!/usr/bin/env bash

set -Eeuo pipefail

readonly COLOR_RED='\033[0;31m'
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[0;33m'
readonly COLOR_BLUE='\033[0;34m'
readonly COLOR_RESET='\033[0m'

pkg_mgr=''

log_error() {
    printf '%b[ERROR]%b %s\n' "${COLOR_RED}" "${COLOR_RESET}" "$@" >&2
}

log_success() {
    printf '%b[SUCCESS]%b %s\n' "${COLOR_GREEN}" "${COLOR_RESET}" "$@"
}

log_warning() {
    printf '%b[WARNING]%b %s\n' "${COLOR_YELLOW}" "${COLOR_RESET}" "$@"
}

log_info() {
    printf '%b[INFO]%b %s\n' "${COLOR_BLUE}" "${COLOR_RESET}" "$@"
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "Run this script as root or with sudo privileges."
        exit 1
    fi
}

check_network() {
    log_info "Checking network connectivity..."
    if ! ping -c 1 -W 2 8.8.8.8 &>/dev/null; then
        log_error "No network connectivity detected"
        exit 1
    fi
    log_success "Network connectivity is OK"
}

detect_package_manager() {
    if command -v apt-get &>/dev/null; then
        pkg_mgr='apt-get'
    else
        log_error "Unsupported package manager: $pkg_mgr"
        exit 1
    fi
    
    log_info "Detected package manager: $pkg_mgr"
}

system_update() {
    local pkg_mgr="$1"
    
    log_info "Updating system with $pkg_mgr..."
    
    if [[ "$pkg_mgr" == "apt-get" ]]; then
        apt-get update -y -qq
        apt-get upgrade -y -qq
    fi
    
    log_success "System updated successfully"
}

main() {
    check_root
    check_network
    detect_package_manager
    system_update "$pkg_mgr"
}

main "$@"