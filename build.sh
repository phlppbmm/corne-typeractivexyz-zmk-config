#!/usr/bin/env bash
# Local ZMK build for corne wireless (nice!nano v2 + nice_view).
# Produces UF2 artifacts in ./artifacts/. Pairs with the GitHub Actions
# workflow in .github/workflows/build.yml.
#
# Prereqs (one-time, see README/notes):
#   - pacman -S arm-none-eabi-{gcc,newlib,binutils} dtc gperf ccache dfu-util
#   - Zephyr SDK 0.16.9 installed at ~/zephyr-sdk-0.16.9 with ARM toolchain
#   - west workspace initialized at this repo root (`west init -l config && west update && west zephyr-export`)
#   - venv at ~/zmk-workspace/.venv with `west` + Zephyr requirements installed

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV="${VENV:-$HOME/zmk-workspace/.venv}"
BOARD="nice_nano/nrf52840/zmk"
SHIELD_COMMON="nice_view_adapter nice_view"

if [[ ! -f "$VENV/bin/activate" ]]; then
  echo "venv not found at $VENV — adjust VENV= or recreate it" >&2
  exit 1
fi
# shellcheck disable=SC1091
source "$VENV/bin/activate"

export CMAKE_POLICY_VERSION_MINIMUM=3.5

build_side() {
  local side="$1"           # left | right
  local shield="corne_${side} ${SHIELD_COMMON}"
  echo ">>> Building $shield"
  west build -p auto -s "$REPO/zmk/app" -d "$REPO/build/$side" -b "$BOARD" -- \
    -DSHIELD="$shield" \
    -DZMK_CONFIG="$REPO/config"
}

build_side left
build_side right

mkdir -p "$REPO/artifacts"
cp "$REPO/build/left/zephyr/zmk.uf2"  "$REPO/artifacts/corne_left-nice_nano_v2-zmk.uf2"
cp "$REPO/build/right/zephyr/zmk.uf2" "$REPO/artifacts/corne_right-nice_nano_v2-zmk.uf2"

echo
echo "Artifacts:"
ls -lh "$REPO/artifacts/"
