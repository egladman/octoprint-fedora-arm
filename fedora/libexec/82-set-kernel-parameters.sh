#!/usr/bin/env bash

set -o errexit -o pipefail

# Logic was pulled directly from https://pagure.io/arm-image-installer/tree/main
kernel::add_parameter () {
    local param="${1:?}"
    log::info "Adding kernel parameter: $param"
    
    # Usage: kernel::add_parameter "string"
    if [[ -f /boot/extlinux/extlinux.conf ]]; then
	log::info "Modifying: /boot/extlinux/extlinux.conf"
	sed -i "s|append|& $param |" /boot/extlinux/extlinux.conf
    elif [[ -f /firmware/EFI/fedora/grub.cfg ]]; then
	log::info "Modifying: /etc/default/grub"
	sed -i "s|GRUB_CMDLINE_LINUX=\"|& $param |" /etc/default/grub
	if [[ -f /firmware/EFI/fedora/grubenv ]]; then
	    log::info "Modifying: /firmware/EFI/fedora/grubenv"
	    sed -i "s|kernelopts=|& $param |" /fw/EFI/fedora/grubenv
	else
	    for spec in /boot/loader/entries/*.conf; do
		log::info "Modifying: $spec"
		sed -i "s|options|& $param|" "$spec"
	    done
	fi
    fi
}

main() {
    kernel::add_parameter "console=ttyS0,115200"

    if [[ $ENABLE_SELINUX -ne 1 ]]; then
	kernel::add_parameter "selinux=0"
    fi

    if [[ $ENABLE_RESCUE -eq 1 ]]; then
	kernel::add_parameter "systemd.unit=rescue.target" # Starts a single-user system without networking
    fi

    if [[ $ENABLE_DEBUG -eq 1 ]]; then
	kernel::add_parameter "systemd.log_level=debug"
    fi
}

init
main "$@"
