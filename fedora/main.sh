#!/usr/bin/env bash

set -o errexit -o pipefail

trap hook::cleanup ERR EXIT SIGINT

hook::cleanup() {
    if [[ ${SKIP_CLEANUP:-0} -eq 1 ]]; then
       log::info "Skipping cleaning up."
       return 0
    fi

    log::info "Cleaning up."
    
    # Unmount paths in the reverse order that they were mounted
    if [[ ${#__MOUNT_PATHS[@]} -gt 0 ]]; then
	mapfile -t mnt_paths < <(util::reverse_order "${__MOUNT_PATHS[@]}")
	for p in "${mnt_paths[@]}"; do
	    log::debug "Processing mount path: $p"
	    dev::umount "$p" || true
	done
    fi

    # Deactivate volume group otherwise we won't beable to detach the loop device later
    log::info "Deactivating volume group: $__VOLUME_GROUP"
    vgchange --activate n "$__VOLUME_GROUP" || true

    # Detaching all devices will clean up state from previous borked runs
    log::info "Detaching all associated loop devices for device: $__LOOP_DEVICE"
    losetup --detach-all "$__LOOP_DEVICE" || true
}

dev::mount() {
    local device mnt_path
    device="${1:?}"
    mnt_path="${2:?}"

    __MOUNT_PATHS+=("$mnt_path") # Global
    
    util::is_mounted "$mnt_path" || {
	log::debug "No existing device mounted at path: $mnt_path"
	log::info "Mounting '$device' to '$mnt_path'"

	util::mkdir "$mnt_path"
	mount "$device" "$mnt_path"
    }
}

dev::umount() {
    local mnt_path
    mnt_path="${1:?}"

    util::is_mounted "$mnt_path" || return 0

    log::info "Unmounting '$mnt_path'"
    umount "$mnt_path"
}

dev::find_loop() {
    local image_path="${1:?}"

    # It's gross but we're redirecting all logs to stderr for we don't interfer with subshell behavior
    log::debug "Searching for existing loop devices." >&2

    local loop_count=0
    losetup --associated "${image_path}" | while read -r loop_device; do
	log::debug "Found loop device: $loop_device" >&2
	loop_count=$((loop_count+1))
    done

    if [[ $loop_count -gt 1 ]]; then
	log::fatal "More than one loop device associated with file: $image_path"
    fi

    __LOOP_DEVICE="$(losetup --find --partscan --show "$image_path")" # Global
    printf '%s\n' "$__LOOP_DEVICE"
}

rootfs::uncompress_image() {
    local src_path dest_path
    src_path="${1:?}"
    dest_path="${2:?}"

    if [[ ! -f "$src_path" ]]; then
	log::error "File does not exist: $src_path"
	return 1
    fi

    if [[ -e "$dest_path" ]]; then
	log::warn "Directory already exists: $dest_path. Skipping decompression."
	return 0
    fi

    # TODO: use builtins
    util::mkdir "$(dirname "$dest_path")"

    log::info "Decompressing '$src_path' to '$dest_path'"
    xz --decompress --keep --stdout "$src_path" > "$dest_path"
}

rootfs::copy_qemu() {
    cp -f ../qemu/bin/qemu-*-static "${1:?}/sbin"
}

rootfs::copy_tools() {
    local rootfs_path tools_path
    rootfs_path="${1:?}"

    tools_path="${rootfs_path}/tools"        
    util::mkdir "$tools_path"
    
    cp -f entrypoint.sh "$tools_path"
    cp -rf libexec "$tools_path"
    cp -rf lib "$tools_path"
    cp -rf rootfs "$tools_path"
    cp -rf ../build/vars "$tools_path"
}

#  Workaround. I had dns issues when using
# systemd-nspawn option `--resolv-conf=copy-host`
rootfs::copy_resolvconf() {
    local rootfs_path
    rootfs_path="${1:?}"

    if [[ -h "${rootfs_path}/etc/resolv.conf" ]]; then
	log::info "Deleting resolv.conf symlink"
	rm -f "${rootfs_path}/etc/resolv.conf"
    fi

    log::info "Copying host resolv.conf"
    cp -f /etc/resolv.conf "${rootfs_path}/etc/resolv.conf"
}

rootfs::mount_image() {
    local image_path rootfs_path
    image_path="${1:?}"
    rootfs_path="${2:?}"

    # We only expect a single device, so we can keep this logic simple for now
    loop_device="$(dev::find_loop "$image_path")"

    log::info "Assigned loop device: $loop_device"
    # The loop device has 3 partitions. The primary rootfs in on partition 3.
    #   loop<n>
    #     loop<n>p1     boot sector
    #     loop<n>p2     /boot
    #     loop<n>p3     /

    # TODO: Do not hardcode the default volume group 'fedora'. I don't expect this
    # to ever change upstream, but just in case.
    local rename_vg=0
    vgdisplay fedora || rename_vg=0
    if [[ $rename_vg -eq 1 ]]; then
	# Volume Group UUID. Not be confused with a system's block device IDs (i.e, blkid).
	# The `vgs` output is indented so we'll (ab)use arrays to strip whitespace
	local vg_uuid
	vg_uuid=($(vgs fedora -o vg_uuid --noheading))
	log::debug "Volume group 'fedora' has uuid '$vg_uuid'"
    
	# If the host and the disk image have the same volume group name then we'll run into issues. As a
	# precaution rename the default volume group name to something less generic than 'fedora'
	# https://askubuntu.com/a/1078061

	# shellcheck disable=SC2128
	log::info "Overriding volume group name for uuid: $vg_uuid"
	# shellcheck disable=SC2128
	vgrename "$vg_uuid" "$__VOLUME_GROUP"
    fi

    # modprobe dm-mod
    log::info "Activating volume group: $__VOLUME_GROUP"
    vgchange --activate y "$__VOLUME_GROUP"

    # /dev/fedora_sbc/root is the logical volume path. Run `lvdisplay` for context. The
    # path is derived from the volume group name (i.e, fedora_sbc)
    log::info "Mounting root partition to path: $rootfs_path"
    dev::mount "/dev/${__VOLUME_GROUP}/root" "${rootfs_path}"

    # FIXME: Don't hardcode labels. These should match /etc/fstab
    log::info "Assigning ${loop_device}p1 label: FedoraEFI"
    dosfslabel "${loop_device}p1" FedoraEFI

    log::info "Mounting firmware partition to path: ${rootfs_path}/firmware"
    dev::mount "${loop_device}p1" "${rootfs_path}/firmware"

    # FIXME: Don't hardcode labels. These should match /etc/fstab
    log::info "Assigning ${loop_device}p2 label: FedoraBoot"
    xfs_admin -L FedoraBoot "${loop_device}p2"

    log::info "Mounting boot partition to path: ${rootfs_path}/boot"
    dev::mount "${loop_device}p2" "${rootfs_path}/boot"
}

rootfs::nspawn() {
    local rootfs_path="${1:?}"

    log::info "Entering rootfs: $rootfs_path"

    declare -a opts=(
	--chdir=/tools
	--resolv-conf=copy-host
	--directory="$rootfs_path"
	--capability=all
    )

    # Any environment variable with the following prefixes will be
    # shared with the systemd-nspawn container
    declare -a shared_envs
    eval 'shared_envs+=(${!'ENABLE_'@})'
    eval 'shared_envs+=(${!'DISABLE_'@})'

    for e in "${shared_envs[@]}"; do
	opts+=(--setenv="$e")
    done

    log::debug "Passing the following options to systemd-nspawn: ${opts[*]}"

    # Disable secomp filtering. Otherwise podman won't function inside the container
    SYSTEMD_SECCOMP=0 \
    SYSTEMD_LOG_LEVEL=debug \
    systemd-nspawn "${opts[@]}" /tools/entrypoint.sh
}

rootfs::compress() {
    local image_path dest_path
    image_path="${1:?}"
    dest_path="${2:?}"

    hook::cleanup

    log::info "Compressing image '$image_path' to '$dest_path'."

    local compression_level=1
    if [[ $ENABLE_RELEASE -eq 1 ]]; then
	compression_level=7
    fi

    xz --stdout -${compression_level} "$image_path" > "$dest_path"
}

init() {
    # Usage: init
   for f in ./lib/*.sh; do
	if [[ $DEBUG -eq 1 ]]; then
	    printf '%s\n' "Loading library: $f"
	fi
	# shellcheck disable=SC1090
	source "$f"
    done
}

main() {
    # Auto-prompt to escalate privileges to superuser
    if [[ $UID -ne 0 ]]; then
        exec sudo -p "${0##*/} must be run as root. Please enter the password for %u to continue: " -- "$0" "$@"
    fi

    local build_dir="../build"
    util::mkdir "${build_dir}/vars"

    while [[ $# -gt 1 ]]; do
	case "$1" in
	    --extra-env)
		# shellcheck disable=SC1090
		source "${2:?}"
		;;
	    --cpu-variant)
		printf '%s\n' "${2:?}" > ../build/vars/${1##--}
		;;
	    --cpu-arch)
		printf '%s\n' "${2:?}" > ../build/vars/${1##--}
		;;
	    --qemu-path)
		printf '%s\n' "${2:?}" > ../build/vars/${1##--}
		;;
	esac
	shift 2
    done
    
    local image rootfs_dir fedora_artifact fedora_artifact_name
    fedora_artifact="${1:?}"                      # .raw.xz compressed rootfs sourced from fedoraproject.org
    fedora_artifact_name="${fedora_artifact##*/}" # basename
    image="${build_dir}/fedora.raw"               # uncompressed rootfs image
    rootfs_dir="${build_dir}/rootfs"              # mounted rootfs path

    # Derive the final compressed image name from the og
    local base suffix
    suffix=".aarch64.raw.xz"
    base="${fedora_artifact_name%%"$suffix"}"

    declare -a wrkarr
    wrkarr=($(util::split "$base" "-"))

    local distro_name distro_variant distro_version
    distro_name="${wrkarr[0]}"
    distro_variant="${wrkarr[1]}"
    distro_version="${wrkarr[2]}-${wrkarr[3]}"
    
    case "${distro_variant,,}" in
	server)
	    true
	    ;;
	*)
	    log::warn "Unable to identify distro variant. This might not work as expected."
	    distro_variant=unknown
	    ;;
    esac

    local octoprint_artifact
    util::mkdir "${build_dir}/dist"
    octoprint_artifact="${build_dir}/dist/Octoprint-${distro_name:?}-${distro_version:?}${suffix}"

    __VOLUME_GROUP="${distro_name,,}"
    #__VOLUME_GROUP="fedora-${fedora_variant}"
    printf '%s\n' "$__VOLUME_GROUP" > ../build/vars/volume-group-name

    # Uncompress fedora artifact 
    rootfs::uncompress_image "$fedora_artifact" "$image"

    # Create loop devices and mount rootfs
    rootfs::mount_image "$image" "$rootfs_dir"

    # Copy source code
    rootfs::copy_tools "$rootfs_dir"

    # Setup networking
    rootfs::copy_resolvconf "$rootfs_dir"

    # Change root
    rootfs::nspawn "$rootfs_dir"

    # Compress final image
    rootfs::compress "$image" "$octoprint_artifact"
}

init
main "$@"
