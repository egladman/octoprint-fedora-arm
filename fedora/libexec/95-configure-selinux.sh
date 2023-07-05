#!/usr/bin/env bash

main() {
    source /etc/selinux/config

    declare -a selinux_envs
    eval 'selinux_envs=(${!'SELINUX'@})'
    
    if [[ $ENABLE_SELINUX -eq 1 ]]; then
	SELINUX=enforcing
    else
	SELINUX=permissive
    fi

    printf '%s\n' "${selinux_envs[@]}" > /etc/selinux/config    
    restorecon -e /proc -e /sys -e /dev -pR /
}

main "$@"
