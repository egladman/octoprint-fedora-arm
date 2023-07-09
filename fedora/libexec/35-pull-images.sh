#!/usr/bin/env bash

set -o errexit -o pipefail

main() {
    local repository=octoprint/octoprint:latest

    log::info "Pulling: ${repository}"
    skopeo copy docker://${repository} containers-storage:${repository}

    log::info "Inspecting: ${repository}"
    skopeo inspect containers-storage:${repository} > /etc/octoprint-release

    cat /etc/octoprint-release


#DEBU[0029] Error pulling candidate docker.io/octoprint/octoprint:latest: copying system image from manifest list: writing blob: adding layer with blob "sha256:d191be7a3c9fa95847a482db8211b6f85b45096c7817fdad4d7661ee7ff1a421": processing tar file(Error: unrecognized command `podman /`
    
    #podman pull --log-level=debug
#    log::info "Saving image"
 #   podman save --format=docker-archive --output=/tmp/octoprint.tar docker.io/octoprint/octoprint:latest

  #  log::info "Loading image"
   # podman load --image=/tmp/octoprint.tar
}

init
main "$@"
