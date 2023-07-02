#!/usr/bin/env sh

set -e

DOCKER="${DOCKER:-docker}"

"$DOCKER" build --file Containerfile --tag qemu-static:latest .

dest_path=../build
if [ ! -d "$dest_path" ]; then
    mkdir -p "$dest_path"
fi

CID="$("$DOCKER" create --quiet qemu-static:latest '')"
"$DOCKER" cp "${CID}":/tools/bin "${dest_path}/bin"
"$DOCKER" container rm "$CID"

printf '%s\n' "Saved qemu static exectuables: $(pwd)/bin)"
