#!/usr/bin/env bash

util::append_to_line() {
    # Usage: util::append_line "regex" "string" "path/to/file"
    # An alternative to sed

    local regex value file_path
    regex="${1:?}"
    value="${2:?}"
    file_path="${3:?}"

    declare -a file_content
    
    local line_count=0
    local line_match=-1
    while read -r line; do
	file_content+=("$line")

	if [[ $line_match -ge 0 ]] || [[ ! "$line" =~ $regex ]]; then
	    continue
	fi

	line_match=$line_count
	log::debug "Line $line_match matches expression: $line"

	line_count=$((line_count+1))
    done < "$file_path"
    
    file_content[$line_match]+="$value"

    # Clear file
    >"$file_path"

    printf '%s\n' "${file_content[@]}" > "$file_path"
}

# Logic was pulled directly from https://pagure.io/arm-image-installer/tree/main
kernel::add_parameter () {
    local param="${1:?}"
    log::info "Adding kernel parameter: $param"
    
    # Usage: kernel::add_parameter "string"
    if [[ -f /boot/extlinux/extlinux.conf ]]; then
	log::info "Modifying: /boot/extlinux/extlinux.conf"
	#util::append_to_line ".*append.*" " $param " /boot/extlinux/extlinux.conf
	sed -i "s|append|& $param |" /boot/extlinux/extlinux.conf
    elif [[ -f /firmware/EFI/fedora/grub.cfg ]]; then
	log::info "Modifying: /etc/default/grub"
	#util::append_to_line ".*GRUB_CMDLINE_LINUX=.*" " $param " /etc/default/grub
	sed -i "s|GRUB_CMDLINE_LINUX=\"|& $param |" /etc/default/grub
	if [[ -f /firmware/EFI/fedora/grubenv ]]; then
	    log::info "Modifying: /firmware/EFI/fedora/grubenv"
	    #util::append_to_line ".*kernelopts=.*" " $param " /firmware/EFI/fedora/grubenv
	    sed -i "s|kernelopts=|& $param |" /fw/EFI/fedora/grubenv
	else
	    for spec in /boot/loader/entries/*.conf; do
		log::info "Modifying: $spec"
		#util::append_to_line ".*options.*" " $param" "$spec"
		sed -i "s|options|& $param|" "$spec"
	    done
	fi
    fi
}

main() {
    kernel::add_parameter "console=ttyS0,115200"
    if [[ $ENABLE_DEBUG -eq 1 ]]; then
	kernel::add_parameter "systemd.unit=rescue.target"
	kernel::add_parameter "systemd.log_level=debug"
	kernel::add_parameter "systemd.log_target=console"
    fi

#    local vg_name vg_name_escaped
#    vg_name="$(<./vars/volume-group-name)"
#    vg_name_escaped="${vg_name//-/--}"    
}

init
main "$@"
