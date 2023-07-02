#!/usr/bin/env bash

set -o errexit -o pipefail

init() {
    # Usage: init
    for f in ./lib/*.sh; do
	if [[ $DEBUG -eq 1 ]]; then
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
	log::info "Executing: $f"

	# TODO: make this not shit
	if [[ "$f" == *"-unprivileged-"* ]]; then
	    log::debug "Executing '$f' as user: octoprint"
	    su octoprint -c "$f"
	    continue
	fi

	"$f"
    done
}

init
main "$@"
