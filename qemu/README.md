# QEMU

## Compile

```
docker build --file Containerfile --tag qemu-static:latest .
```

## Install

Copy executable to `bin`

```
mkdir bin || true
cid=$(docker create --quiet qemu-static:latest "")
docker cp ${cid}:/bin bin
docker container rm $cid
```
