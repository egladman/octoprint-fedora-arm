util::mkdir() {
    # Usage: util::mkdir dir...
    log::debug "Called by '${FUNCNAME[1]}' with args: $*"    
    for p in "$@"; do
	if [[ -d "$p" ]]; then
	   continue
	fi

	log::debug "Creating directory: ${p}"
	mkdir -p "$p"
    done
}

util::reverse_order() {
    # Usage: util::reverse_order string...
    declare -a wrkarr
    for i in "$@"; do
	wrkarr=("$i" "${wrkarr[@]}")
    done

    printf '%s\n' "${wrkarr[@]}"
}

util::split() {
   # Usage: util::split string delimiter
   IFS=$'\n' read -d "" -ra arr <<< "${1//$2/$'\n'}"
   printf '%s\n' "${arr[@]}"
}

util::is_mounted() {
    # Usage util::is_mounted path/to/mount
    local mnt_path
    mnt_path="${1:?}"

    log::debug "Checking if a device is mounted at path: $mnt_path"
    mountpoint -q "$mnt_path"
}
