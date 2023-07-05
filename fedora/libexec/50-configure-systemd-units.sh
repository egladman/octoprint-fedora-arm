#!/usr/bin/env bash

set -o errexit -o pipefail

main() {
    log::info "Copying octoprint systemd generator executable: /usr/lib/systemd/system-generators/octoprint-bootstrap"
    cp -f rootfs/usr/lib/systemd/system-generators/octoprint-bootstrap /usr/lib/systemd/system-generators/

    log::info "Enabling systemd timer: podman-auto-update"
    #systemd::enable_timer podman-auto-update
    systemctl --root=/ enable podman-auto-update.service
}

init
main "$@"
