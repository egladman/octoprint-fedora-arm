#!/usr/bin/env bash

set -o errexit -o pipefail

main() {

    declare -a dnf_opts=(
	--assumeyes
    )

    dnf remove "${dnf_opts[@]}" \
	zram-generator
}

init
main "$@"
