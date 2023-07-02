#!/usr/bin/env bash

set -o errexit -o pipefail

main() {
    log::info "Enabling ssh daemon systemd service"
    systemctl enable sshd.service
}

init
main "$@"
