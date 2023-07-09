#!/usr/bin/env bash

set -o errexit -o pipefail

main() {
    if [[ ! -d /var/lib/systemd ]]; then
	mkdir /var/lib/systemd
    fi

    # Allows systemd-logind to start 
    if [[ ! -f /usr/lib/systemd/systemd-logind ]]; then
	touch /usr/lib/systemd/systemd-logind
    fi
}

init
main "$@"
