# macbook12-audio-driver

WIP audio driver for the CS4208 codec found in the 12" MacBook (MacBook9,1, MacBook10,1), compiling on kernels 5.0+, including 6.17+.

Based on davidjo's [snd_hda_macbookpro](https://github.com/davidjo/snd_hda_macbookpro) and the original [leifliddy/macbook12-audio-driver](https://github.com/leifliddy/macbook12-audio-driver).

> **This driver is experimental. Use at your own risk.**

## Supported Hardware

| Model | Identifier | Status |
|---|---|---|
| MacBook 12" (2016) | MacBook9,1 | Supported |
| MacBook 12" (2017) | MacBook10,1 | Supported |
| MacBook 12" (2015) | MacBook8,1 | **Not supported** |

## Supported Kernels

- **5.0 – 6.16**: Uses the `patch_cirrus` codec path
- **6.17+**: Uses the new `cs420x` codec path (sound/hda/codecs/cirrus)

## Prerequisites

Install build tools, DKMS, kernel headers, and `wget` (used to download kernel source for building).

### Arch Linux

```bash
sudo pacman -S dkms gcc linux-headers make wget
```

### Fedora

```bash
sudo dnf install dkms gcc kernel-devel make wget
```

### Ubuntu / Debian

```bash
sudo apt install dkms gcc linux-headers-generic make wget
```

## Step 1 — Clone This Repository

```bash
git clone https://github.com/juicecultus/macbook12-audio-driver.git
cd macbook12-audio-driver
```

## Step 2 — Build and Install via DKMS (Recommended)

DKMS will automatically recompile the module whenever you update your kernel.

```bash
# run as root or with sudo
sudo ./install.cirrus.driver.sh -i
```

This will:
1. Download the matching kernel source from kernel.org
2. Extract and patch the HDA codec source
3. Build the `snd-hda-codec-cs420x` module
4. Register it with DKMS for automatic rebuilds on kernel updates

After installation, **reboot** to load the new module:

```bash
sudo reboot
```

### Alternative — Manual Build (without DKMS)

If you prefer not to use DKMS:

```bash
# run as root or with sudo
sudo ./install.cirrus.driver.sh
sudo reboot
```

> **Note:** With a manual install you will need to rebuild the module every time your kernel updates.

## Step 3 — Verify

After rebooting, verify the module is loaded:

```bash
lsmod | grep snd_hda_codec_cs420x
```

Check DKMS status:

```bash
dkms status
```

Expected output:

```
macbook12-audio/0.1, <kernel-version>, x86_64: installed
```

Test audio output:

```bash
# List audio devices
aplay -l

# Play a test tone
speaker-test -c 2
```

## Uninstalling

### DKMS

```bash
sudo ./install.cirrus.driver.sh -u
```

### Manual

```bash
sudo rm /lib/modules/$(uname -r)/updates/snd-hda-codec-cs420x.ko*
sudo depmod -a
sudo reboot
```

## Troubleshooting

- **No audio after install** — Reboot is required. Check `dmesg | grep snd` for errors.
- **Module fails to build** — Ensure `linux-headers` matches your running kernel (`uname -r`). On Arch, install `linux-headers`; on Ubuntu, `linux-headers-generic`; on Fedora, `kernel-devel`.
- **Kernel source download fails** — Ensure `wget` is installed and you have internet connectivity. The script downloads from `cdn.kernel.org`.
- **DKMS not rebuilding on kernel update** — Verify DKMS status with `dkms status`. Re-run `sudo ./install.cirrus.driver.sh -i` if needed.
- **Wrong audio device selected** — Use `pavucontrol` or `alsamixer` to select the correct output device.

## How It Works

The install script downloads the kernel source matching your running kernel, extracts the HDA sound subsystem, and replaces the stock Cirrus/CS420x codec driver with a patched version that adds proper support for the MacBook 12" audio hardware. On kernels 6.17+, the driver targets the new `sound/hda/codecs/cirrus/` path; on older kernels, it patches `sound/pci/hda/patch_cirrus.c`.

## License

This project inherits the license from the upstream Linux kernel HDA subsystem (GPL).
