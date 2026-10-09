# Vial setup
VIA_ENABLE = yes
VIAL_ENABLE = yes

# Match personal keymap config (OLED on, RGB off)
RGB_MATRIX_ENABLE = no
RGBLIGHT_ENABLE = no

## Build target
# RP2040 controller (Pro Micro-compatible RP2040-CE)
CONVERT_TO = rp2040_ce
# AVR (Pro Micro / Elite-C): comment out CONVERT_TO above

# Save flash on atmega32u4 (firmware overflowed by ~7 KB)
ifeq ($(strip $(CONVERT_TO)), )
    MOUSEKEY_ENABLE = no
    COMBO_ENABLE = no
    KEY_OVERRIDE_ENABLE = no
    QMK_SETTINGS = no
    CAPS_WORD_ENABLE = no
    REPEAT_KEY_ENABLE = no
    LAYER_LOCK_ENABLE = no
endif
