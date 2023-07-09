#!/usr/bin/env bash

set -o errexit -o pipefail

main() {
    log::info "Copying systemd unit(s) to directory: /usr/lib/systemd/system"
    cp -rf rootfs/usr/lib/systemd/system/. /usr/lib/systemd/system/

    if [[ $ENABLE_AUTOUPDATES -eq 1  ]]; then
	log::info "Enabling systemd timer: podman-auto-update"
	systemctl --root=/ enable podman-auto-update.service
    fi

    log::info "Enabling systemd service: octoprint-bootstrap"
    systemctl --root=/ enable octoprint-bootstrap.service

    log::info "Disabling systemd service: initial-setup.service"
    systemctl --root=/ disable initial-setup.service
    # Initial-setup walks the user through the following on first boot:
    #  - Language Settings
    #  - Date & Time
    #  - Language Settings
    #  - Root Password
    #  - User Creation
    # These are all things that we manage elsewhere or simply don't care about

    log::info "Disabling systemd service: dnf-makecache.service"
    systemctl --root=/ disable dnf-makecache.service
    # This will fail since the rootfs is read-only. Users are
    # unable to install packages by desigin
}

init
main "$@"
