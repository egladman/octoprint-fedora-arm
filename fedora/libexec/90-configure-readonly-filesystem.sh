#!/usr/bin/env bash

main() {
    log::info "Setting filesystem to read only."

    log::info "Creating file: /etc/sysconfig/readonly-root"
    cp -f ./rootfs/etc/sysconfig/readonly-root /etc/sysconfig/readonly-root
}

init
main "$@"
