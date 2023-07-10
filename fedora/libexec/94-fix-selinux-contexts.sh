#!/usr/bin/env bash

main() {
    restorecon -e /proc -e /sys -e /dev -pR /
}

main "$@"
