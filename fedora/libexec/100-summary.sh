#!/usr/bin/env bash

main() {
    df -h /var/lib/containers
}

main "$@"
