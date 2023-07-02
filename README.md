# octoprint-fedora-arm

Octoprint for ARM single board computers. A Fedora-based alternative to [OctoPi](https://github.com/guysoft/OctoPi) with the following enchancments:

- Read-only filesystem
- Container-based

## Build

1. Download the corresponding raw aarch64 image from [fedoraproject.org](https://fedoraproject.org/server/download/) and save it to the working directory

2. Verify checksums

3. Build image

```
make boards/arm64/v8/generic
```

*Note:* The image will be placed in the working directory.

## Install

Dependencies:

- `arm-image-installer` [link](https://packages.fedoraproject.org/pkgs/arm-image-installer/arm-image-installer/)

```
arm-image-installer --media=/dev/XXX --resizefs --target=none --image=Octoprint-38-1.6.aarch64.raw.xz
```

## Development

### QEMU

```
make setup-qemu
sudo make setup-binfmt
```

# Commonly Asked Questions

1. What's the default username/password for the unprivileged user?

- Username: `octoprint`
- Password: `octoprint`

2. I can't delete `build`, it says its busy

```
sudo umount build/rootfs/boot
sudo umount build/rootfs
sudo vgchange -an fedora-server`
sudo losetup -D build/disk.raw
```

3. I can't delete `build`, it says permission denied

```
sudo rm -irf build
```
