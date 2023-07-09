#!/usr/bin/env bash

set -o errexit -o pipefail

main() {
    local repository=octoprint/octoprint:latest

    log::info "Pulling: ${repository}"
    podman pull ${repository} || log::warn "Failed to pull: ${repository}"

    log::info "Inspecting labels: ${repository}"
    podman image inspect --format='{{ range $k, $v := .Labels }}{{ $k }}: {{$v}}\n{{end}}' $repository > /etc/octoprint-release || log::warn "Failed to inspect: ${repository}"

    if [[ -f /etc/octoprint-release ]]; then
	cat /etc/octoprint-release
    fi
}

init
main "$@"
