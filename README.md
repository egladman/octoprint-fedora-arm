# octoprint-fedora-arm

An immutable [Octoprint](https://octoprint.org/) ARM image with an emphasis on stability. Set it and forget it. This project was inspired by [OctoPi](https://github.com/guysoft/OctoPi).

## Features

- Read-only filesystem
- Container-based
- Application auto-updates
  - Disabled by default
- Device Autodiscovery
  - On boot all relevant [character devices](https://en.wikipedia.org/wiki/Device_file) (i.e, serial ports, cameras) will be made accessible to Octoprint

## Hardware Requirements

- Minimum of 4GB RAM
  - Everything lives in RAM. This includes the root filesystem and container hence it's heavier than traditional octoprint install.

## Persistence

1. Format a usb flashdrive with the following settings:
- label: `OCTOPRINT`

2. While off insert the usb flashdrive into the device.

3. Power on the device. Octoprint config settings will be written to the flashdrive.

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
sudo octoprint-readonly disable
passwd octo
sudo octoprint-readonly enable
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

6. How do a run a command as `root` if a password isn't set for it?

While logged in as `octo` run:

```
sudo su -
whoami
```

7. Is it possible to temporarily enable write access to the root filesystem?

```
sudo octoprint-readonly disable
```

Once you're done making changes remount as readonly

```
sudo octoprint-readonly enable
```
