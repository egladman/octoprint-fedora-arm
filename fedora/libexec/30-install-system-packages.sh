#!/usr/bin/env bash

set -o errexit -o pipefail

main() {
    if [[ $ENABLE_RELEASE -eq 0 ]] && [[ $ENABLE_READONLY -eq 0 ]]; then
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
	skopeo
	vim-minimal
    )

    if [[ $ENABLE_READONLY -eq 1 ]]; then
	packages+=(readonly-root)
    fi

    dnf install "${dnf_opts[@]}" "${packages[@]}"
}

init
main "$@"
