#!/usr/bin/env bash

set -o errexit -o pipefail

main() {
    dnf clean all
    rm -rf /tools || :
    rm -rf /tmp/* || :
}

init
main "$@"
