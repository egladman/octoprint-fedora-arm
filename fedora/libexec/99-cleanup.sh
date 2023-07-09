#!/usr/bin/env bash

main() {
    dnf clean all
    rm -rf /tools || :
    rm -rf /tmp/* || :

    restorecon -e /proc -e /sys -e /dev -pR /
}

main "$@"
