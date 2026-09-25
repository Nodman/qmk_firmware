#include "keymap.h"

#define CTL_ESC MT(MOD_LCTL, KC_ESC)

const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
    [_ML] = LAYOUT(
        KC_ESC,  KC_F1,   KC_F2,   KC_F3,   KC_F4,   KC_F5,   KC_F6,   KC_F7,    KC_F8,    KC_F9,   KC_F10,  KC_F11,  KC_F12,            KC_PSCR, KC_SCRL, KC_MUTE, \
        KC_GRV,  KC_1,    KC_2,    KC_3,    KC_4,    KC_5,    KC_6,    KC_7,     KC_8,     KC_9,    KC_0,    KC_MINS, KC_EQL,  KC_BSPC,  KC_MPRV, KC_MNXT, KC_VOLU, \
        KC_TAB,  KC_Q,    KC_W,    KC_E,    KC_R,    KC_T,    KC_Y,    KC_U,     KC_I,     KC_O,    KC_P,    KC_LBRC, KC_RBRC, KC_BSLS,  KC_DEL,  KC_MPLY, KC_VOLD, \
        CTL_ESC, KC_A,    KC_S,    KC_D,    KC_F,    KC_G,    KC_H,    KC_J,     KC_K,     KC_L,    KC_SCLN, KC_QUOT, KC_ENT, \
        KC_LSFT, KC_Z,    KC_X,    KC_C,    KC_V,    KC_B,    KC_N,    KC_M,     KC_COMM,  KC_DOT,  KC_SLSH, KC_RSFT,                             KC_UP, \
        KC_LCTL, KC_LALT, KC_LGUI,                   KC_SPC,                               KC_RGUI, TT(_FL),KC_APP,  KC_RCTL,            KC_LEFT, KC_DOWN, KC_RGHT \
    ),
    // Plain Ctrl on Caps: tap-hold would delay Ctrl in games.
    [_GL] = LAYOUT(
        _______, _______, _______, _______, _______, _______, _______, _______,  _______,  _______, _______, _______, _______,           _______, _______, _______, \
        KC_F13,  _______, _______, _______, _______, _______, _______, _______,  _______,  _______, _______, _______, _______,  _______,  _______, _______, _______, \
        _______, _______, _______, _______, _______, _______, _______, _______,  _______,  _______, _______, _______, _______,  _______,  _______, _______, _______, \
        KC_LCTL, _______, _______, _______, _______, _______, _______, _______,  _______,  _______, _______, _______, _______, \
        _______, _______, _______, _______, _______, _______, _______, _______,  _______,  _______, _______, _______,                             _______, \
        _______, _______, KC_F14,                    _______,                              KC_F14,  _______, _______, _______,           _______, _______, _______ \
    ),
    [_FL] = LAYOUT(
        _______, DM_PLY1, DM_PLY2, _______, _______, DM_REC1, DM_REC2, _______,  DM_RSTP,  _______, _______, _______, _______,           _______, _______, EE_CLR,
        _______, KC_BRID, KC_BRIU, _______, _______, _______, _______, _______,  _______,  _______, _______, _______, _______,  _______, _______, _______, _______,
        RGB_M_P, RGB_SPD, RGB_VAI, RGB_SPI, RGB_HUI, RGB_SAI, _______, U_T_AUTO, U_T_AGCR, _______, PROFILE, _______, _______, _______, _______, _______, _______,
        _______, RGB_RMOD,RGB_VAD, RGB_MOD, RGB_HUD, RGB_SAD, _______, _______,  _______,  _______, _______, _______, _______,
        _______, RGB_TOG, _______, _______, _______, MD_BOOT, NK_TOGG, _______,  _______,  _______, _______, _______,                             _______,
        _______, _______, _______,                   _______,                              _______, TG(_FL), _______, _______,           _______, _______, _______
    ),
    /*
    [X] = LAYOUT(
        _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______,            _______, _______, _______, \
        _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______,   _______, _______, _______, \
        _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______,   _______, _______, _______, \
        _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, \
        _______, _______, _______, _______, _______, _______, NK_TOGG, _______, _______, _______, _______, _______,                              _______, \
        _______, _______, _______,                   _______,                            _______, _______, _______, _______,            _______, _______, _______ \
    ),
    */
};

#ifdef _______
#undef _______
#define _______ {0, 0, 0}

const uint8_t PROGMEM ledmap[][DRIVER_LED_TOTAL][3] = {
    // _ML has no entry: all zeros means the normal RGB effect shows through.
    [_GL] = {
        RED,     MAGENT,  MAGENT,  MAGENT,  MAGENT,  _______, _______, _______, _______, _______, _______, _______, _______,          _______, _______, _______,
        GREEN,   PINK,    PINK,    PINK,    GREEN,   _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______,
        ORANGE,  GREEN,   TEAL,    GREEN,   GREEN,   GREEN,   GREEN,   CYAN,    CYAN,    CYAN,    _______, _______, _______, _______, _______, _______, _______,
        _______, TEAL,    TEAL,    TEAL,    GREEN,   CORAL,   CORAL,   CYAN,    CYAN   , _______, _______, _______, _______,
        _______, PINK,    PINK,    PINK,    PINK,    PINK,    PINK,    _______, _______, _______, _______, _______,                            _______,
        ORANGE,  ORANGE,  ORANGE,                    GREEN,                              ORANGE,  RED,     ORANGE,  ORANGE,           _______, _______, _______
    },
    [_FL] = {
        _______, CORAL,   CORAL,   _______, _______, CORAL,   CORAL,   _______, CORAL,   _______, _______, _______, _______,          _______, _______, RED,
        _______, PINK,    PINK,    _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______,
        ORANGE,  ORANGE,  ORANGE,  ORANGE,  ORANGE,  ORANGE,  _______, RED,     RED,     _______, YELLOW,  _______, _______, _______, _______, _______, _______,
        _______, ORANGE,  ORANGE,  ORANGE,  ORANGE,  ORANGE,  _______, _______, _______, _______, _______, _______, _______,
        _______, ORANGE,  _______, _______, _______, AZURE,   AZURE,   _______, _______, _______, _______, _______,                            _______,
        _______, _______, _______,                   _______,                            _______, PINK,    _______, _______,          _______, _______, _______
    },
};

#undef _______
#define _______ KC_TRNS
#endif

static uint8_t led_mode;

static void apply_led_mode(void) {
    switch (led_mode) {
        case LED_MODE_KEYS:
            rgb_matrix_set_flags_noeeprom(LED_FLAG_KEYLIGHT | LED_FLAG_MODIFIER);
            rgb_matrix_set_color_all(0, 0, 0);
            rgb_matrix_enable_noeeprom();
            break;
        case LED_MODE_UNDERGLOW:
            rgb_matrix_set_flags_noeeprom(LED_FLAG_UNDERGLOW);
            rgb_matrix_set_color_all(0, 0, 0);
            rgb_matrix_enable_noeeprom();
            break;
        case LED_MODE_OFF:
            rgb_matrix_set_flags_noeeprom(LED_FLAG_NONE);
            rgb_matrix_disable_noeeprom();
            break;
        default:
            rgb_matrix_set_flags_noeeprom(LED_FLAG_ALL);
            rgb_matrix_enable_noeeprom();
            break;
    }
}

void keyboard_post_init_user(void) {
    led_mode = eeconfig_read_user() % LED_MODE_COUNT;
    apply_led_mode();
}

bool process_record_user(uint16_t keycode, keyrecord_t *record) {
    static uint32_t key_timer;

    switch (keycode) {
        case U_T_AUTO:
            if (record->event.pressed && MODS_SHIFT && MODS_CTRL) {
                TOGGLE_FLAG_AND_PRINT(usb_extra_manual, "USB extra port manual mode");
            }
            return false;
        case U_T_AGCR:
            if (record->event.pressed && MODS_SHIFT && MODS_CTRL) {
                TOGGLE_FLAG_AND_PRINT(usb_gcr_auto, "USB GCR auto mode");
            }
            return false;
        case MD_BOOT:
            if (record->event.pressed) {
                key_timer = timer_read32();
            } else {
                if (timer_elapsed32(key_timer) >= 500) {
                    reset_keyboard();
                }
            }
            return false;
        // QMK runs RGB_TOG on release, so block both press and release.
        case RGB_TOG:
            if (record->event.pressed) {
                led_mode = (led_mode + 1) % LED_MODE_COUNT;
                eeconfig_update_user(led_mode);
                apply_led_mode();
            }
            return false;
    }

    if (record->event.pressed) {
        switch (keycode) {
            case PROFILE:
                set_single_persistent_default_layer(get_highest_layer(default_layer_state) == _GL ? _ML : _GL);
                return false;
        }
    }
    return true;
}

static void set_scaled_color(int index, HSV hsv) {
    RGB rgb = hsv_to_rgb(hsv);
    float f = (float)rgb_matrix_config.hsv.v / UINT8_MAX;
    rgb_matrix_set_color(index, f * rgb.r, f * rgb.g, f * rgb.b);
}

void set_layer_color(int layer) {
    for (int i = 0; i < DRIVER_LED_TOTAL; i++) {
        HSV hsv = {
            .h = pgm_read_byte(&ledmap[layer][i][0]),
            .s = pgm_read_byte(&ledmap[layer][i][1]),
            .v = pgm_read_byte(&ledmap[layer][i][2]),
        };
        if (hsv.h || hsv.s || hsv.v) {
            set_scaled_color(i, hsv);
        } else if (layer == _FL) {
            // On FN, turn off LEDs of keys with no function so the FN keys stand out.
            rgb_matrix_set_color(i, 0, 0, 0);
        }
    }
}

void rgb_matrix_indicators_user(void) {
    if (rgb_matrix_get_flags() == LED_FLAG_NONE ||
        rgb_matrix_get_flags() == LED_FLAG_UNDERGLOW) {
            return;
        }
    set_layer_color(get_highest_layer(layer_state | default_layer_state));

    if (is_caps_word_on()) {
        set_scaled_color(LED_LSFT, (HSV){HSV_RED});
        set_scaled_color(LED_RSFT, (HSV){HSV_RED});
    }
}
