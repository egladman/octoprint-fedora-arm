#!/usr/bin/env bash

set -o errexit -o pipefail

main() {
    log::info "Size of path: /var/lib/containers"
    du -sh /var/lib/containers

    log::info "Installed packages"
    dnf list installed

    log::info "Enabled systemd services"
    systemctl --root=/ list-unit-files --type=service --state=enabled
}

init
main "$@"
