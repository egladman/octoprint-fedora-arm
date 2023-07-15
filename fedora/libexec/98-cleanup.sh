#!/usr/bin/env bash

main() {
    dnf clean all
    rm -rf /tools || :
    rm -rf /tmp/* || :
}

main "$@"
