#!/usr/bin/env bash

main() {
    # It's important that we're only removing files. See 95-configure-selinux.sh

    dnf clean all
    rm -rf /tools || :
    rm -rf /firmware || :
    rm -rf /tmp/* || :
}

main "$@"
