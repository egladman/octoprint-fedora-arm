# octoprint-fedora-sbc

Octoprint without the bloat for single board computers

## Build

```
make boards/arm64/v8/raspberrypi_3
```

The final image with suffix `.octoprint.raw.xz` will be placed in the working directory

## QEMU

```
make setup-qemu
sudo make setup-binfmt
```
