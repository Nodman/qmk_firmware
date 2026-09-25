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
- **Gaming**: Main with its own lighting. Only mapped keys light up; the rest and underglow are off.
  - `~` = F13, both Cmd keys = F14.
  - Caps = plain Ctrl (no tap-hold delay).

## Fn layer

Hold Fn, or tap it twice to lock.

| Keys | Action |
|---|---|
| Fn+H | Type this cheat sheet as one line (host input must be English/US) |
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
| Fn+Esc | Clear status lights (killed sessions stay gone, live ones return on next event) |
| Fn+Pause | Reset EEPROM (all saved settings) |
| Ctrl+Shift+Fn+U | Extra USB port: auto / always on |
| Ctrl+Shift+Fn+I | LED current auto-limit on/off |

## Other

- Caps Word: tap both Shifts. The next word is typed in caps. Shift keys glow red while it is on.
- Lights turn off when the computer sleeps (USB suspend).

## Status lights (Raw HID)

The Mac sets key colors over Raw HID. Shown in every light mode (Fn+Z off too), hidden while Fn is held. RAM only: lost on unplug, the next hook event restores them.

- Tool: `host/ctrl-led.swift`. Build: `xcrun swiftc -O host/ctrl-led.swift -o ~/.local/bin/ctrl-led`
- Manual: `ctrl-led set f1 orange blink`, `ctrl-led off f1`, `ctrl-led clear`
- While any of F1–F9 has a status, the other F1–F9 keys go dark.

### Claude Code sessions

- Esc: summary. Red if any session needs you, else orange if any works, else green.
- F1–F9: one key per session. Orange slow blink = working, red fast blink = question or permission, green = standby.
- `ctrl-led claude list` shows which key is which session.
- `ctrl-led claude reset` forgets all sessions.
- Hooks in `~/.claude/settings.json`: `ctrl-led claude` (timeout 5) on SessionStart, SessionEnd, UserPromptSubmit, Stop, StopFailure, Notification, and with matcher `*` on PreToolUse, PostToolUse, PostToolUseFailure, PermissionRequest, PermissionDenied.
