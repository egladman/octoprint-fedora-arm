#!/usr/bin/env bash

set -o errexit -o pipefail

main() {
    if [[ ! -f /usr/lib/systemd/systemd-logind ]]; then
	touch /usr/lib/systemd/systemd-logind
    fi
}

init
main "$@"
