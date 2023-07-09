#!/usr/bin/env bash

set -o errexit -o pipefail

main() {
    if [[ $ENABLE_RELEASE -eq 0 ]] && [[ $ENABLE_READONLY -eq 0 ]]; then
	log::warn "Skipping: $0"
	return 0
    fi

    declare -a dnf_opts=(
	--assumeyes
    )

    declare -a packages=(
	'anaconda*'
	bubblewrap
	cockpit
	diffutils
	dnf
	dos2unix
	fedora-logos
	nvidia-gpu-firmware
	os-prober
	zram-generator
    )

    log::info "Uninstalling the following packages: ${packages[*]}"
    dnf remove "${dnf_opts[@]}" "${packages[@]}"
}

init
main "$@"
