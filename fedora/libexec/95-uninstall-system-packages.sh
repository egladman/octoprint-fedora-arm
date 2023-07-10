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
	abrt
	'anaconda*'
	bubblewrap
	cockpit
	cyrus-sasl-plain
	cyrus-sasl-gssapi
	diffutils
	dos2unix
	fedora-logos
	'perl*'
	teamd
	traceroute
	nvidia-gpu-firmware
	'qemu*'
	quota
	sos
	'sssd*'
	whois
	yajl
    )

    log::info "Uninstalling the following packages: ${packages[*]}"
    dnf remove "${dnf_opts[@]}" "${packages[@]}"
}

init
main "$@"
