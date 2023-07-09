#!/usr/bin/env bash

set -o errexit -o pipefail

main() {
    declare -A ssh_rules=(
	["LoginGraceTime"]="20"
	["MaxAuthTries"]="3"
	# ["PasswordAuthentication"]="no"
	["PermitRootLogin"]="no"
	["PermitEmptyPasswords"]="no"
    )

    log::info "Hardening sshd config: /etc/ssh/sshd_config"
    local regex
    for rule in "${!ssh_rules[@]}"; do
	regex="s/#\?\(${rule}\s*\).*$/\1 ${ssh_rules[${rule}]}/"
	sed -i "$regex" /etc/ssh/sshd_config
    done

    log::info "Enabling systemd service: sshd"
    systemctl --root=/ enable sshd
}

init
main "$@"
