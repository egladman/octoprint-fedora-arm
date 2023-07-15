#!/usr/bin/env bash

set -o errexit -o pipefail

main() {
    if [[ $ENABLE_RELEASE -eq 0 ]] && [[ $ENABLE_READONLY -eq 0 ]]; then
	log::warn "Skipping: $0"
	return 0
    fi

    declare -a dnf_opts=(
	--setopt=install_weak_deps=False
	--assumeyes
    )

    declare -a packages=(
        firewalld
	iputils
	podman
	openssh-server
    )

    if [[ $ENABLE_READONLY -eq 1 ]]; then
	packages+=(readonly-root)
    fi

    log::info "Installing the following packages: ${packages[*]}"
    dnf install "${dnf_opts[@]}" "${packages[@]}"
}

init
main "$@"
