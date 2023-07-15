#!/usr/bin/env bash

main() {
    log::info "Size of path: /var/lib/containers"
    df -h /var/lib/containers

    log::info "Installed packages"
    dnf list installed

    log::info "Enabled systemd services"
    systemctl --root=/ list-unit-files --type=service --state=enabled
}

main "$@"
