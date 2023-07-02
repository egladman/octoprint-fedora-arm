#!/usr/bin/env bash

set -o errexit -o pipefail

main() {
    log::info "Pulling octoprint image."
    podman pull docker.io/octoprint/octoprint:latest

    log::info "Creating pod."
    podman pod create --name=octoprint

    util::mkdir "${HOME}/octoprint"
    
    log::info "Adding octoprint to newly created pod."
    podman create \
	   --pod=octoprint \
	   --device /dev/ttyACM0:/dev/ttyACM0 \
	   --device /dev/video0:/dev/video0 \
	   --name=service \
	   --volume=${HOME}/octoprint:/octoprint \
	   --env ENABLE_MJPG_STREAMER=true \
	   --publish 80:80 \
	   docker.io/octoprint/octoprint:latest

    util::mkdir "${HOME}/.config/systemd/user"
    pushd "${HOME}/.config/systemd/user"
    podman generate systemd --new --files --name octoprint
    popd

    log::info "Enabling octoprint systemd service"
    systemctl --user enable pod-octoprint.service
}

init
main "$@"
