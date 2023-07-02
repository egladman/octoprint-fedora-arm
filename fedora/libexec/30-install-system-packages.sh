#!/usr/bin/env bash

set -o errexit -o pipefail

main() {
    dnf --assumeyes install \
	podman \
	readonly-root \
	openssh-server
}

init
main "$@"
