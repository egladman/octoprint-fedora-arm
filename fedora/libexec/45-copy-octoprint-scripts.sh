#!/usr/bin/env bash

set -o errexit -o pipefail

main() {
    cp -f rootfs/usr/bin/octoprint-* /usr/bin/
}

init
main "$@"
