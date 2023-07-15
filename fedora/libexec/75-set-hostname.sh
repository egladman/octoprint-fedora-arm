#!/usr/bin/env bash

set -o errexit -o pipefail

main() {
    log::info "Setting hostname."

    printf '%s\n' "octoprint" > /etc/hostname
    hostname octoprint
}

init
main "$@"
