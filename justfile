# Justfile for the Aurora Corne (RP2040) Vial build.
# Run `just` to list recipes, `just <recipe>` to run one.
# Full notes: keyboards/splitkb/aurora/corne/keymaps/vial/

# Keyboard target and keymap used by all recipes below
kb := "splitkb/aurora/corne/rev1"
km := "vial"
target := kb + ":" + km

# Show the recipe list by default
default:
    @just --list

# ---------------------------------------------------------------
# 1. ONE-TIME SETUP (only needed on a fresh machine)
# ---------------------------------------------------------------

# Install the build toolchain for the RP2040 board.
# Needs sudo; you will be asked for your password.
# The RP2040 build only needs the ARM toolchain.
deps:
    sudo apt update
    sudo apt install -y gcc-arm-none-eabi libnewlib-arm-none-eabi
    # Optional, only for ATmega32U4 (Pro Micro / Elite-C) boards:
    # sudo apt install -y gcc-avr avr-libc binutils-avr avrdude dfu-programmer

# Install the QMK CLI with uv. `make` calls `qmk hello` before building,
# so the CLI must work. Re-run this if you see segfaults or missing modules.
qmk-install:
    uv tool install --force qmk

# Check the toolchain and QMK CLI are working.
# If `qmk hello` fails, run `just qmk-install`.
check:
    arm-none-eabi-gcc --version | head -1
    qmk hello || echo "qmk CLI is broken, run: just qmk-install"

# Optional: `qmk setup` clones a separate qmk_firmware repo. You do NOT need it
# for this repo, since everything builds from the repo root with `make`.
# qmk-setup:
#     qmk setup -y

# ---------------------------------------------------------------
# 2. BUILD
# ---------------------------------------------------------------

# Build the RP2040 firmware (creates splitkb_aurora_corne_rev1_vial.uf2 in repo root).
# Uses CONVERT_TO = rp2040_ce from keymaps/vial/rules.mk.
build:
    make {{target}}

# Remove build output. Use this if a build fails with odd errors.
clean:
    rm -rf .build
    rm -f splitkb_aurora_corne_rev1_vial.uf2 splitkb_aurora_corne_rev1_vial.hex

# ---------------------------------------------------------------
# 3. FLASH (RP2040 uses UF2 drag and drop, not `make flash`)
# ---------------------------------------------------------------

# Copy the built UF2 to a mounted RPI-RP2 drive.
# In WSL, Windows drives are under /mnt. Find the letter with `ls /mnt`
# (usually /mnt/d or /mnt/e), then run: just flash drive=/mnt/e
#
# Steps for EACH half (flash one at a time):
#   1. Plug the half into USB.
#   2. Double-tap the reset button (side of the PCB, next to the TRRS jack).
#   3. The RPI-RP2 drive appears in Windows Explorer.
#   4. Run `just flash drive=/mnt/<letter>`. The half reboots when the copy finishes.
#   5. Unplug it and repeat for the other half.
drive := "/mnt/e"
flash:
    #!/usr/bin/env bash
    set -euo pipefail
    uf2="splitkb_aurora_corne_rev1_vial.uf2"
    if [ ! -f "$uf2" ]; then
        echo "No $uf2 found. Run: just build"
        exit 1
    fi
    if [ ! -d "{{drive}}" ]; then
        echo "Drive {{drive}} not found. Check the letter with: ls /mnt"
        exit 1
    fi
    cp "$uf2" "{{drive}}/"
    echo "Copied $uf2 to {{drive}}. The half will reboot by itself."

# Build and flash in one step (you still need to double-tap reset first).
build-flash: build flash

# ---------------------------------------------------------------
# 4. NOTES (no commands)
# ---------------------------------------------------------------
# * Keymap:      keyboards/splitkb/aurora/corne/keymaps/vial/keymap.c
#                (copy of keymaps/personal, layer 3 J key = AG_TOGG, Win/Mac Alt-GUI swap)
# * Vial layout: keyboards/splitkb/aurora/corne/keymaps/vial/vial.json
# * Vial UID:    keyboards/splitkb/aurora/corne/keymaps/vial/config.h (keep this stable)
# * RP2040:      rules.mk sets CONVERT_TO = rp2040_ce. For an AVR Pro Micro board,
#                comment that line out (the AVR build also needs the trims in rules.mk).
# * Layer 3 J:   toggles Alt/GUI swap (Windows <-> Mac). Stored in EEPROM.
# * If Vial shows the old keymap after flashing, change the key in the Vial app.
