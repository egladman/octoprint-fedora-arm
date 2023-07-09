#!/usr/bin/env bash

set -o errexit -o pipefail

main() {
    log::info "Creating container policy: /etc/containers/policy.json"
    cp -f rootfs/etc/containers/policy.json /etc/containers/
}

init
main "$@"
