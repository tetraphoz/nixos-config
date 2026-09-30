# Hyprland session

This is the optional Wayland session for the P52. XMonad/Xmobar remains the
Ly default; the shared Home Manager profile installs both environments. The
Hyprland setup is focused on the same keyboard-driven workflow, with native
Wayland support for WiVRn/WayVR.

## Configuration map

| File | Purpose |
| --- | --- |
| `hyprland.conf` | Main compositor settings, startup commands, window behavior, and keybindings. |
| `pyprland.toml` | IPC-based dropdown terminal/music scratchpads and the expose overview. |
| `hyprsunset.conf` | Evening color-temperature schedule. |
| `random-wallpaper` | Select a wallpaper from `/media/img/wallpapers`, set it through Hyprpaper IPC, and refresh the shared Pywal palette. |
| `screenshot` | Region screenshots and OCR-to-clipboard. |
| `workspace` | Allocates globally unique workspace IDs on the currently focused output. |
| `virtual-output` | Lists, creates, configures, and removes runtime headless outputs for XR screens. |
| `window-picker` | Wofi window selector; `bring` moves the selection to the current workspace. |
| `toggle-border` | Toggle the compositor border width. |
| `PROGRESS.md` | Migration notes, validated behavior, and follow-up work. |

Home Manager owns package installation and the generated Hyprpaper, Hypridle,
and Hyprlock configs in `home/hyprland.nix`. It links Pyprland and Hyprsunset
configs from this directory. Waybar's config is in `dotfiles/waybar/`; the
shared palette is generated at `~/.cache/wal/` by Pywal.

## Components

- **Waybar** is the bottom status bar. Its modules include workspaces, active
  window, clock, MPRIS, brightness, CPU/memory/temperature, network, audio,
  battery, and tray.
- **Pyprland** uses Hyprland IPC (not a version-coupled native plugin ABI) for
  the dropdown `kitty` terminal and `ncmpcpp` window, plus the expose overview.
  Its daemon is started with the session; its config lives at
  `~/.config/pypr/config.toml`.
- **Hyprpaper** changes wallpapers. `hypr-random-wallpaper` also regenerates
  Pywal colors so Kitty, Rofi, Dunst, and Waybar share the current palette.
- **Hypridle/Hyprlock** lock after five minutes idle and turn off displays
  after eight minutes. Display wake resumes DPMS.
- **Hyprsunset** switches to 4800 K at 20:30 local time and returns to neutral
  at 07:30. These are fixed local-time profiles, not astronomical sunset times.
- **SwayOSD** provides feedback for hardware volume, mic-mute, and brightness
  keys. **Hyprpicker** copies a selected color to the clipboard.
- **Polkit** uses the shared Home Manager launcher `~/.local/bin/polkit-agent`;
  XMonad and Hyprland both start the same agent.

## Monitors and persistence

The main config sources `~/.config/hypr/monitors.conf`, which is mutable user
state managed by `nwg-displays`. Explicit mode/position choices belong there;
the main config also supplies a generic preferred-mode/automatic-placement
fallback for any output not listed, including headless XR outputs. This lets
the laptop run with only `eDP-1`, dock to a projector or `DP-3`, or add several
virtual outputs without workspace rules tied to specific connector names.

Hyprland workspace IDs are global and unique, but workspace navigation is
scoped to the focused output. `Super+Left/Right` cycles that output's existing
workspaces; the number row selects a local workspace slot; Waybar only shows
workspaces belonging to its own output. Waybar labels are the globally unique
workspace IDs, while number-row shortcuts are local ordinals (the second
workspace on one output may have a different ID than the second on another).
`Super+N` creates the next global ID on the focused output, and `Super+Ctrl+N`
moves the active window to a new workspace. Empty inactive workspaces are not pinned forever; keep a window on a
desktop to retain it. Use `Super+W` / `Super+Shift+W` to cycle output focus,
`Super+Ctrl+W` to move the active window to the next output, or `Super+Alt` plus
a direction for spatial focus/move actions. These bindings work with any
number and arrangement of physical or headless outputs.

## Quest 3, WiVRn, WayVR, and virtual outputs

Breezy Desktop is not the right compositor integration for this setup: its
[desktop effects](https://github.com/wheaney/breezy-desktop/tree/v2.12.2) target
KDE Plasma 6 or GNOME and supported XR glasses. The [Breezy maintainer's Quest 3
compatibility response](https://github.com/wheaney/breezy-desktop/issues/137)
says Quest 3 is not currently supported and points Quest users toward
VR-oriented solutions. This host therefore keeps the existing WiVRn + WayVR
path.

[WayVR](https://github.com/wayvr-org/wayvr) is the VR overlay/screen-capture
application; it does not create Hyprland outputs. Hyprland 0.55.4 supports
creating runtime headless outputs.
Use these Home Manager commands while logged into Hyprland:

```sh
hypr-virtual-output list
hypr-virtual-output add VR-1 1920x1080@60 1
hypr-virtual-output add VR-2 2560x1440@60 1
hypr-virtual-output remove VR-2
```

`add` creates a headless output, applies the selected mode/scale, and places it
automatically. It defaults to 1920×1080@60 at scale 1. Output names must start
with `VR-`; this protects physical connector names from accidental removal.
These outputs are runtime-only: recreate the ones needed for a session rather
than autostarting unused displays. Removing an output with occupied workspaces
moves those windows to the remaining outputs; the helper warns and requires
confirmation, but move important windows first if you want to control placement.
Start or restart WayVR after creating them,
then grant screen-capture access to the intended screens in the order requested
by the [WayVR first-start guide](https://github.com/wayvr-org/wayvr#first-start).
If a screen was selected incorrectly, WayVR documents clearing its PipeWire
tokens and restarting the software. Test one virtual output first; more/larger
outputs increase rendering and capture load. The Quest 3/WayVR capture and
re-selection behavior still needs live validation on this host.

The laptop's physical modes remain user-editable in `monitors.conf` (for
example, docked `DP-3` at 2560×1440@60). New physical outputs and runtime
headless outputs use the generic fallback unless explicitly configured.

## Keybindings

`$mainMod` is Super. This table lists the session-specific and most-used
bindings; the config is authoritative.

| Binding | Action |
| --- | --- |
| Super+Return / Super+D | Kitty / Wofi app launcher |
| Super+Q / Super+Shift+Q | Reload / exit Hyprland |
| Super+Shift+C | Close active window |
| Super+J/K | Focus down/up |
| Super+H/L | Adjust master area width |
| Super+Shift+J/K | Swap window down/up |
| Super+1…9,0 / Super+Shift+1…9,0 | Switch to / move window to the Nth workspace on the focused output |
| Super+Left/Right / Super+Shift+Left/Right | Cycle workspaces on this output / move window to previous or next local workspace |
| Super+N / Super+Ctrl+N | Create a workspace here / move active window to a newly created workspace |
| Super+W / Super+Shift+W | Focus next / previous output in Hyprland's output order |
| Super+Ctrl+W / Super+Ctrl+Shift+W | Move active window to next / previous output and follow it |
| Super+Alt+Arrow / Super+Alt+Shift+Arrow | Focus / move window to the output in that direction |
| Super+B | Toggle Waybar visibility |
| Super+A or Super+G | Open window picker; Super+Shift+G brings it to this workspace |
| Super+Backspace | Toggle terminal scratchpad |
| Super+Shift+Y | Toggle ncmpcpp scratchpad |
| Super+Tab | Toggle Pyprland expose overview |
| Super+Shift+L | Lock screen |
| Super+Alt+C | Pick a color and copy it |
| Print / Ctrl+Print | Save a selected region / OCR it to the clipboard |
| Super+Shift+U | Change wallpaper and Pywal palette |
| XF86Audio* / XF86MonBrightness* | SwayOSD volume/mute/brightness controls |

`Super+Y` opens the existing media-control submap: press Y to play/pause, P
for previous, or N for next. Escape leaves the submap.

## Validation and troubleshooting

From `/etc/nixos`:

```sh
Hyprland --verify-config --config dotfiles/hypr/hyprland.conf
nix run nixpkgs#pyprland -- validate
nix eval --raw .#nixosConfigurations.p52.config.system.build.toplevel.drvPath
```

The Pyprland validator reads `~/.config/pypr/config.toml`; after applying the
Home Manager generation, run it directly. To validate the checked-in TOML
without activating it, copy it under a temporary `$XDG_CONFIG_HOME/pypr/config.toml`
and run `pypr validate` with that environment.

For live-session diagnostics:

```sh
hyprctl configerrors
hyprctl monitors -j | jq
hyprctl workspaces -j | jq
hyprctl clients -j | jq
journalctl --user -b | rg -i 'hypr|pypr|waybar|hyprpaper|hypridle|swayosd'
```

`monitors.conf` is mutable user state and should be checked separately when
monitor detection or scaling is wrong. If Hyprland does not start, choose the
XMonad session from Ly; it remains the default recovery desktop.
