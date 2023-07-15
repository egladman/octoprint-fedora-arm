#!/usr/bin/env bash

set -o errexit -o pipefail

main() {
    if [[ $ENABLE_RELEASE -eq 0 ]] && [[ $ENABLE_READONLY -eq 0 ]]; then
	log::warn "Skipping: $0"
	return 0
    fi

    declare -a dnf_opts=(
	--assumeyes
	--noautoremove
    )

    declare -a packages=(
	'anaconda*'
	bubblewrap
	cockpit
	fedora-logos
	'perl*'
    )

    if [[ $ENABLE_ZRAM -eq 0 ]]; then
	packages+=('zram-generator*')
    fi

    log::info "Uninstalling the following packages: ${packages[*]}"
    dnf remove "${dnf_opts[@]}" "${packages[@]}"
}

init
main "$@"
