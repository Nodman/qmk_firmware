#include QMK_KEYBOARD_H
#include "raw_hid.h"

// These are just to make it neater to use builtin HSV values in the keymap
#define RED {HSV_RED}
#define CORAL {HSV_CORAL}
#define ORANGE {HSV_ORANGE}
#define GOLDEN {HSV_GOLDENROD}
#define GOLD {HSV_GOLD}
#define YELLOW {HSV_YELLOW}
#define CHART {HSV_CHARTREUSE}
#define GREEN {HSV_GREEN}
#define SPRING {HSV_SPRINGGREEN}
#define TURQ {HSV_TURQUOISE}
#define TEAL {HSV_TEAL}
#define CYAN {HSV_CYAN}
#define AZURE {HSV_AZURE}
#define BLUE {HSV_BLUE}
#define PURPLE {HSV_PURPLE}
#define MAGENT {HSV_MAGENTA}
#define PINK {HSV_PINK}
#define WHITE {HSV_WHITE}

// LED indexes, see config_led.c
#define LED_LSFT 63
#define LED_RSFT 74

extern rgb_config_t rgb_matrix_config;
// Defined in rgb_matrix.c but missing from rgb_matrix.h in QMK 0.18.
void rgb_matrix_set_flags_noeeprom(led_flags_t flags);

enum layout_names {
    _ML=0,       // Main Layout: The main keyboard layout that has all the characters
    _GL,         // Gaming Layout: Main layout with extra F-keys and its own lighting
    _FL,         // Function Layout: The function key activated layout with default functions and some added ones
};

// Fn+Z lighting modes, in cycle order. Saved in the user EEPROM slot.
enum led_modes {
    LED_MODE_ALL = 0,
    LED_MODE_KEYS,
    LED_MODE_UNDERGLOW,
    LED_MODE_OFF,
    LED_MODE_COUNT,
};

// Status lights over Raw HID (usage page 0xFF60, 32-byte reports). Host tool: host/ctrl-led.swift
// SET:       [STATUS_CMD_SET, led, r, g, b, mode]   mode STATUS_OFF clears the LED
// CLEAR_ALL: [STATUS_CMD_CLEAR_ALL]
enum status_commands {
    STATUS_CMD_SET = 0x01,
    STATUS_CMD_CLEAR_ALL = 0x02,
};

enum status_modes {
    STATUS_OFF = 0,
    STATUS_SOLID,
    STATUS_BLINK,
    STATUS_BLINK_FAST,
    STATUS_MODE_COUNT,
};

#define STATUS_SLOW_MS 500
#define STATUS_FAST_MS 150
#define STATUS_MIN_VAL 96
// F1..F9: other keys here go dark while a status shows here, so status keys stand out.
#define STATUS_DARK_FIRST 1
#define STATUS_DARK_LAST 9

enum ctrl_keycodes {
    U_T_AUTO = SAFE_RANGE, // USB Extra Port Toggle Auto Detect / Always Active
    U_T_AGCR,              // USB Toggle Automatic GCR control
    MD_BOOT,               // Restart into bootloader after hold timeout
    PROFILE,               // Switch between Main and Gaming profiles, saved in EEPROM
    HELP,                  // Type a one-line FN cheat sheet
};
