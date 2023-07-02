#!/usr/bin/env bash

set -o errexit -o pipefail

main() {
    local username="admini"

    log::info "Checking if user '${username}' exists."
    id "$username" && {
	log::info "User '${username}' already exists. Skipping."
	return 0
    }

    log::info "Creating user: ${username}"
    adduser --groups wheel "$username"

    log::info "Changing password for user: ${username}"
    log::debug "Setting password value to user's name. This is not secure."
    printf '%s:%s\n' "$username" "$username" | chpasswd
}

init
main "$@"
