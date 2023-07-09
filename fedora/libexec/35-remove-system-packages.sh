#!/usr/bin/env bash

set -o errexit -o pipefail

main() {
    if [[ $ENABLE_RELEASE -ne 1 ]]; then
	return 0
    fi

    declare -a dnf_opts=(
	--assumeyes
    )

    dnf remove "${dnf_opts[@]}" \
	zram-generator
}

init
main "$@"
