#!/usr/bin/env bash

set -o errexit -o pipefail

main() {
    mkdir -m 755 -p /usr/lib/systemd/systemd-logind || :
}

init
main "$@"
