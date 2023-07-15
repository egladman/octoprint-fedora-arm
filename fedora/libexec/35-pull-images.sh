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

    mkdir -p /var/lib/containers2
    mv -f /var/lib/containers/storage /var/lib/containers2/storage
}

init
main "$@"
