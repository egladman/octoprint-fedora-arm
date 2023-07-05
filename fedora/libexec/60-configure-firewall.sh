#!/usr/bin/env bash

set -o errexit -o pipefail

main() {
    log::info "Enabling systemd service: firewalld"
    systemctl --root=/ enable firewalld
    
    log::info "Opening port 80"
    firewall-offline-cmd --zone=public --add-service=http

    log::info "Opening port 22"
    firewall-offline-cmd --zone=public --add-service=ssh
}

init
main "$@"
