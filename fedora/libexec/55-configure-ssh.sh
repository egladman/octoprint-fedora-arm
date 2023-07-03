#!/usr/bin/env bash

set -o errexit -o pipefail

main() {
    log::info "Enabling ssh daemon systemd service"

    local unit_name unit_path
    unit_name="sshd.service"
    unit_path="/usr/lib/systemd/system/${unit_name}"

    # Enable without directly calling `systemctl`
    ln -sf "$unit_path" "/etc/systemd/system/multi-user.target.wants/${unit_name}"
}

init
main "$@"
