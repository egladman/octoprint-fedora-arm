#!/usr/bin/env bash

set -o errexit -o pipefail

main() {
    local registry repository uri
    registry=docker.io/octoprint/
    repository=octoprint:latest
    uri="${registry}${repository}"

    log::info "Pulling: $uri"
    podman pull $uri || log::warn "Failed to pull: $uri"

    log::info "Inspecting labels: $uri"
    podman image inspect --format='{{ range $k, $v := .Labels }}{{ $k }}: {{$v}}\n{{end}}' $uri > /etc/octoprint-release || log::warn "Failed to inspect: $uri"

    if [[ -f /etc/octoprint-release ]]; then
	cat /etc/octoprint-release
    fi

    if [[ ! -d /etc/octoprint/containers/archives ]]; then
	mkdir -p /etc/octoprint/containers/archives
    fi

    # EPOCHSECONDS is a bash builtin introduced in Bash 5.0
    podman save --output "/etc/octoprint/containers/archives/${EPOCHSECONDS:?}.tar" "$uri" || log::warn "Failed to export: $uri"

    # Nuke everything
    podman system reset
}

init
main "$@"
