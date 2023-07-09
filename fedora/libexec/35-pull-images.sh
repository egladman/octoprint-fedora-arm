#!/usr/bin/env bash

set -o errexit -o pipefail

main() {
    local repository=octoprint/octoprint:latest

    log::info "Pulling: ${repository}"
    skopeo copy docker://${repository} containers-storage:${repository} || log::warn "Failed to pull: ${repository}"

    log::info "Inspecting: ${repository}"
    skopeo inspect containers-storage:${repository} > /etc/octoprint-release || log::warn "Failed to inspect: ${repository}"

    if [[ -f /etc/octoprint-release ]]; then
	cat /etc/octoprint-release || :
    fi
}

init
main "$@"
