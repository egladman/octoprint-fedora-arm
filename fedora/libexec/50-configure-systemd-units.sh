#!/usr/bin/env bash

set -o errexit -o pipefail

main() {
    log::info "Copying bootstrap script: /usr/bin/octoprint-bootstrap"
    cp -f rootfs/usr/bin/octoprint-bootstrap /usr/bin/

    local unit_name unit_path
    unit_name="octoprint-firstboot.service"
    unit_path="/usr/lib/systemd/system/${unit_name}"
    log::info "Copying firstboot systemd unit: ${unit_path}"
    cp -f "rootfs${unit_path}" "$unit_path"

    # Enable without directly calling `systemctl`
    ln -sf "$unit_path" "/etc/systemd/system/multi-user.target.wants/${unit_name}"
}

init
main "$@"
