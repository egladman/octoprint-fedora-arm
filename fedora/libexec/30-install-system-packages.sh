#!/usr/bin/env bash

set -o errexit -o pipefail

main() {

    declare -a dnf_opts=(
	--setopt=install_weak_deps=False
	--assumeyes
    )

    dnf install "${dnf_opts[@]}" \
        firewalld \
	podman \
	openssh-server \
	skopeo \
	readonly-root \
	vim-minimal
}

init
main "$@"
