#!/usr/bin/env bash

set -o errexit -o pipefail

main() {
    util::mkdir /media/removable
}

init
main "$@"
