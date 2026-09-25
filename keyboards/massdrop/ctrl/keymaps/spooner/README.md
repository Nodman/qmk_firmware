# Massdrop CTRL: spooner

Based on the `endgame` keymap. QMK 0.18.6 (last QMK with CTRL v1 support is 0.26.11).

## Build and flash

- Build: `make massdrop/ctrl:spooner` (or `util/docker_build.sh massdrop/ctrl:spooner`)
- Flash: `mdloader --first --download massdrop_ctrl_spooner.bin --restart`, then Fn+B (hold 0.5 s)
- mdloader 1.0.6+ turns on SmartEEPROM while flashing. Without it, saved settings reset on unplug.

## Profiles (Fn+P, saved)

- **Main**: TKL layout.
  - Caps: tap = Esc, hold = Ctrl.
  - Mac-style bottom row: Win key = Alt, Alt = Cmd, Right Alt = Right Cmd.
  - Top right: PrtSc, ScrLk, Mute.
  - Nav block: Ins/Home = prev/next track, PgUp/PgDn = volume, End = play/pause.
- **Gaming**: Main with its own lighting.
  - `~` = F13, both Cmd keys = F14.
  - Caps = plain Ctrl (no tap-hold delay).

## Fn layer

Hold Fn, or tap it twice to lock.

| Keys | Action |
|---|---|
| Fn+P | Switch profile Main / Gaming |
| Fn+Z | Lights: all → keys → underglow → off (saved) |
| Fn+D / A | Next / previous effect |
| Fn+Tab | Solid color |
| Fn+W / S | Brightness up / down |
| Fn+R / F | Hue up / down |
| Fn+T / G | Saturation up / down |
| Fn+E / Q | Effect speed up / down |
| Fn+1 / 2 | Screen brightness down / up |
| Fn+F5 / F6 | Record macro 1 / 2 |
| Fn+F8 | Stop recording |
| Fn+F1 / F2 | Play macro 1 / 2 (lost on unplug) |
| Fn+N | NKRO on/off |
| Fn+B (hold) | Bootloader |
| Fn+Pause | Reset EEPROM (all saved settings) |
| Ctrl+Shift+Fn+U | Extra USB port: auto / always on |
| Ctrl+Shift+Fn+I | LED current auto-limit on/off |

## Other

- Caps Word: tap both Shifts. The next word is typed in caps. Shift keys glow red while it is on.
- Lights turn off when the computer sleeps (USB suspend).
