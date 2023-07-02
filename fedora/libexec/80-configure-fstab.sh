#!/usr/bin/env bash

main() {
    log::info "Creating file: /etc/fstab"
    cp -f ./rootfs/etc/fstab /etc/fstab
}

init
main "$@"
