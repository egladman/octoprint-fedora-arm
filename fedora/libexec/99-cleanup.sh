#!/usr/bin/env bash

main() {
    dnf clean all
    
    rm -rf /tools || :
    util::umount /proc/cpuinfo
}

main "$@"
