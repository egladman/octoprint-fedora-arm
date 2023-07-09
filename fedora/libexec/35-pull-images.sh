#!/usr/bin/env bash

set -o errexit -o pipefail

main() {
    local repository=octoprint/octoprint:latest

    log::info "Pulling: ${repository}"
    skopeo copy docker://${repository} containers-storage:${repository}

    log::info "Inspecting: ${repository}"
    skopeo inspect containers-storage:${repository} > /etc/octoprint-release

    cat /etc/octoprint-release
}

init
main "$@"
