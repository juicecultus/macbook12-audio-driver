#!/bin/bash

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
action="manual"
kernel_release="$(uname -r)"

usage() {
  cat <<USAGE
Usage: $0 [--install | --uninstall] [--kernel KERNEL_RELEASE] [--kernel-source DIR]

  -i, --install             Install with DKMS (recommended)
  -u, -r, --uninstall      Remove the DKMS installation
  -k, --kernel RELEASE      Manually build for RELEASE (default: uname -r)
  --kernel-source DIR        Use an existing kernel source tree
USAGE
}

while (($#)); do
  case "$1" in
    -i|--install)
      action="install"
      shift
      ;;
    -r|-u|--remove|--uninstall)
      action="remove"
      shift
      ;;
    -k|--kernel)
      [[ -n ${2:-} ]] || {
        echo "$1 must be followed by a kernel release" >&2
        exit 2
      }
      kernel_release="$2"
      shift 2
      ;;
    --kernel-source)
      [[ -n ${2:-} ]] || {
        echo "$1 must be followed by a source directory" >&2
        exit 2
      }
      export MACBOOK12_AUDIO_KERNEL_SOURCE="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

cd "$script_dir"

case "$action" in
  install)
    "$script_dir/dkms.sh" install
    ;;
  remove)
    "$script_dir/dkms.sh" remove
    ;;
  manual)
    "$script_dir/prepare.cirrus.driver.sh" "$kernel_release"
    make KERNELRELEASE="$kernel_release"
    make KERNELRELEASE="$kernel_release" install
    ;;
esac
