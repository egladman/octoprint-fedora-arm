#!/usr/bin/env bash

set -o errexit -o pipefail

main() {
    # This path is referenced in /etc/rwtab, but it must first exist
    # otherwise the systemd-rfkill.service unit fails to start
    log::info "Creating directory: /var/lib/systemd/rfkill"
    mkdir -p /var/lib/systemd/rfkill

    log::info "Creating directory: /var/lib/octoprint"
    mkdir -p /var/lib/octoprint
}

init
main "$@"
