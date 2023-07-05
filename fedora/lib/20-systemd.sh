systemd::enable() {
    # Usage: systemd::enable "unit" "name"
    #        systemd::enable service sshd
    local unit_type unit_name unit_mode
    unit_type="${1:?}"
    unit_name="${2:?}"
    unit_mode="${3:-system}"
    unit_wants="${4:-multi-user}.target.wants"

    # Systemd supports way more search paths, but our use-case is simple
    # https://www.freedesktop.org/software/systemd/man/systemd.unit.html
    case "$unit_mode" in
	system)
	    src_prefix="/usr/lib/systemd/system"
	    dest_prefix="/etc/systemd/system"
	    ;;
	*)
	    return 1
	    ;;
    esac

    ln -svf "${src_prefix}/${unit_name}.${unit_type}" "${dest_prefix}/${unit_wants}/${unit_name}.${unit_type}"
}

systemd::enable_service() {
    # Usage: systemd::enable_service "name"
    systemd::enable service "${1:?}" system "${2:-multi-user}"
}

systemd::enable_timer() {
    systemd::enable timer "${1:?}" system "${2:-timers}"
}
