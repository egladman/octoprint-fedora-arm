#!/usr/bin/env bash

set -o errexit -o pipefail

main() {
    log::info "Setting filesystem to read only."

    log::info "Creating file: /etc/sysconfig/readonly-root"
    cp -rf ./rootfs/etc/sysconfig/. /etc/sysconfig/

    log::info "Configure writable directories."
    cp -rf ./rootfs/etc/rwtab.d/. /etc/rwtab.d/

    if [[ $ENABLE_READONLY -eq 0 ]]; then
	# By the time autorelabeling runs the rootfs is readonly. Hence
	# it will fail. So lets pretend it already ran
	log::info "Creating file: /.autorelablel"
	>"/.autorelabel"
    fi
}

init
main "$@"
