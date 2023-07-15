#!/usr/bin/env bash

set -o errexit -o pipefail

init() {
    # Usage: init
    for f in ./lib/*.sh; do
	if [[ $ENABLE_DEBUG -eq 1 ]]; then
	   printf '%s\n' "Loading library: $f"
	fi
	# shellcheck disable=SC1090
	source "$f"
    done
}

main() {
    export -f init
    
    # Useful for manually running scripts while chrooted
    if [[ $# -gt 0 ]]; then
	for f in "$@"; do
	    log::info "Executing: $f"
	    "$f"
	done
	exit 0
    fi

    for f in ./libexec/*.sh; do
	if [[ ! -x "$f" ]]; then
	    log::fatal "File is not executable: $f"
	fi

	log::info "Executing: $f"
	"$f"
    done
}

init
main "$@"
