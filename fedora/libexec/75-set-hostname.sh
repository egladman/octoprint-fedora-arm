#!/usr/bin/env bash

main() {
    log::info "Setting hostname."

    printf '%s\n' "octoprint" > /etc/hostname
    hostname octoprint
}

init
main "$@"
