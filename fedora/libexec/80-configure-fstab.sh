#!/usr/bin/env bash

set -o errexit -o pipefail

main() {
    log::info "Creating file: /etc/fstab"
    cp -f ./rootfs/etc/fstab /etc/fstab
}

init
main "$@"
