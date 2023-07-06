#!/usr/bin/env bash

set -o errexit -o pipefail

main() {
    log::info "Copying octoprint systemd generator(s) to directory: /usr/lib/systemd/system-generators"
    cp -rf rootfs/usr/lib/systemd/system-generators/. /usr/lib/systemd/system-generators/

    log::info "Enabling systemd timer: podman-auto-update"
    systemctl --root=/ enable podman-auto-update.service

    log::info "Disabling systemd service: initial-setup.service"
    systemctl --root=/ enable initial-setup.service
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
