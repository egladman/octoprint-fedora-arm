# octoprint-fedora-arm

A purpose-built Octoprint ARM image with an emphasis on stability, and ease of use. This project was inspired by [OctoPi](https://github.com/guysoft/OctoPi).

## Features

- Read-only filesystem
- Container-based
- Auto-updates
- Device Autodiscovery
  - On boot all relevant [character devices](https://en.wikipedia.org/wiki/Device_file) (i.e, serial ports, cameras) will be made accessible to Octoprint

## Considerations

In an effort to reduce the overall image size, the container image is not include shipped image. On first boot it's downloaded.

## Build

1. Download the corresponding raw aarch64 image from [fedoraproject.org](https://fedoraproject.org/server/download/) and save it to the working directory

2. Verify checksums

3. Build image

```
make boards/arm64/v8/generic
```

*Note:* The image will be placed in `build/dist`

## Install

### xzcat
```
xzcat Octoprint-Fedora-38-1.6.aarch64.raw.xz| dd of=/dev/XXX oflag=direct bs=4M status=progress && sync
```

### [arm-image-installer](https://packages.fedoraproject.org/pkgs/arm-image-installer/arm-image-installer/)
```
arm-image-installer --media=/dev/XXX --resizefs --target=none --image=Octoprint-Fedora-38-1.6.aarch64.raw.xz
```

## Post Install

1. SSH into the machine

```
ssh octo@octoprint
```

2. Change the default password for user `octo`

```
passwd octo
```

## Development

Dependencies:

- `systemd-nspawn`
- `qemu`
- `make`
- `bash`

### QEMU

```
make setup-qemu
sudo make setup-binfmt
```

### Debugging

#### Raspberry Pi

If the device fails to start then attach a serial cable and watch the logs

```
screen /dev/ttyUSB0 115200
```

To exit `screen`, type `Control-A k`.

# Commonly Asked Questions

1. What's the default username/password for the unprivileged user?

- Username: `octo`
- Password: `octo`

2. I can't delete `build`, it says its busy

```
sudo umount build/rootfs/boot
sudo umount build/firmware
sudo umount build/rootfs
sudo vgchange -an fedora
sudo losetup -D build/fedora.raw
```

3. I can't delete `build`, it says permission denied

```
sudo rm -irf build
```

4. Something is messed up, how do I blow away the existing container?

Delete the lockfile, then on next boot the container will reinitialize

```
rm -if /home/octo/octoprint/.lockfile
```

5. I want to reset everything, how can I do that?


Delete the entire octoprint directory. On next boot everything will be cleared.

```
rm -irf /home/octo/octoprint
```
