#!/usr/bin/env bash

set -o errexit -o pipefail

main() {
    restorecon -e /proc -e /sys -e /dev -pR /
}

init
main "$@"
