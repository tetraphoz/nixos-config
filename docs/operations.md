# Operating this system

Run commands from the repository root (`/etc/nixos` on the configured host).

## Validate and apply changes

```sh
nix fmt
nix flake check
nix build .#nixosConfigurations.p52.config.system.build.toplevel --dry-run
sudo nixos-rebuild test --flake .#p52
sudo nixos-rebuild switch --flake .#p52
```

`test` activates the configuration for the current boot without making it the
new boot default. After confirming it works, use `switch` to make it the
current system generation. The `ns` and `nst` Zsh aliases run the switch and
test commands respectively.

Home Manager is integrated with this NixOS flake, so `nixos-rebuild` applies
the system and user configurations together; no separate Home Manager command
is needed. The flake also exposes a standalone `tetra` output for independent
deployments:

```sh
nix run github:nix-community/home-manager/release-26.05 -- switch --flake .#tetra
```

Both configurations include the XMonad and Hyprland modules. NixOS controls
which sessions Ly offers by enabling their system modules; XMonad and Hyprland
are enabled on this host.

## Desktop sessions

XMonad is the default Ly session. Select **Hyprland** in Ly for the optional
Wayland desktop and the WiVRn/WayVR path. Its user
configuration is managed alongside the XMonad config by Home Manager. Use
`nwg-displays` to arrange physical monitors and select modes; it saves settings
to `~/.config/hypr/monitors.conf`. Hyprland has a generic preferred-mode
fallback, and workspace rules are not tied to connector names, so the same
session works on the laptop panel alone, with the dock/projector, or with
runtime headless outputs. Hyprland workspace IDs remain globally unique;
`Super+Left/Right` cycles workspaces on the focused output, the number row
selects local workspace slots, and `Super+N` creates a new workspace there.
Waybar shows each output's own workspace list. `Super+W` / `Super+Shift+W`
cycles output focus; Super+Ctrl+W moves the active window to the next output, with
spatial `Super+Alt+Arrow` alternatives. Waybar is positioned at the bottom.
The Hyprland profile mirrors the main XMonad shortcuts; `Super+Q` reloads Hyprland,
`Super+Shift+Q` exits, and `Super+Shift+C` closes a window. `Super+Backspace`
toggles the terminal scratchpad, `Super+Shift+Y` toggles the ncmpcpp scratchpad,
and `Super+Tab` opens Pyprland's expose overview. `Super+Alt+C` picks a color
with hyprpicker; Print saves a region screenshot and Ctrl+Print copies OCR text.
Hyprsunset applies its configured warm-color profile after 20:30 local time
and restores neutral color at 07:30. Hardware volume, mic-mute, and brightness
keys use SwayOSD to show their changes. Graphical authentication prompts use
the shared Polkit agent in either session.

### Quest 3 virtual outputs

Breezy Desktop is designed for KDE Plasma/GNOME and supported XR glasses; its
maintainer has said Quest 3 is not currently supported. The Quest setup uses
WiVRn with WayVR instead. WayVR captures desktop screens for VR but does not
create Hyprland outputs. Create headless outputs before starting/restarting
WayVR, then select the desired screens in the portal:

```sh
hypr-virtual-output list
hypr-virtual-output add VR-1 1920x1080@60 1
hypr-virtual-output add VR-2 2560x1440@60 1
hypr-virtual-output remove VR-2
```

The helper manages only runtime `VR-*` headless outputs; it does not persist
them or alter the real monitor layout. Removing an output with open workspace
windows migrates those windows to remaining outputs; the helper warns and asks
for confirmation. Move important windows first if you need precise placement.
Start with one 1080p output, then test additional outputs and modes for capture
latency, GPU load, and Quest streaming quality. WayVR may need its PipeWire
screen tokens cleared and the software restarted after changing which screens
it captures.

In the X11 session, the idle-lock timer locks after 15 minutes unless a
fullscreen application or audio playback is active. The separate logind lock
on suspend still applies.

## Nix workflow tools

The developer package set includes:

- `nh` for NixOS rebuild and cleanup workflows.
- `nix-output-monitor` (`nom`) for readable build output.
- `nvd` for comparing NixOS generations.
- `statix` and `deadnix` for Nix linting and unused-code checks.
- `nix-index` for searching the package database for commands/files.

`nix fmt` uses the formatter pinned by the flake. `nix flake check` checks the
flake outputs; the dry-run build explicitly evaluates the NixOS system output
and shows what would be built before switching.

## Updating inputs

```sh
nix flake update
nix flake check
sudo nixos-rebuild test --flake .#p52
```

Review `flake.lock` changes, especially when updating Nixpkgs: the fingerprint,
WiVRn, and REAPER overrides intentionally track upstream sources and may need
adjustment. Once the test activation is satisfactory, switch as usual. The
`nfu` Zsh alias runs `nix flake update` from `/etc/nixos`.

## Rollback and generations

If a new generation has problems, select an older generation in the boot menu
or switch back from a running system:

```sh
sudo nixos-rebuild switch --rollback
```

The system keeps up to 10 boot entries and runs weekly garbage collection,
removing unreferenced store paths older than 30 days. Do not expect garbage
collection to preserve generations or package paths that are no longer rooted.

## Service checks

### Tailscale, SSH, Sunshine, and SimpleX

```sh
sudo tailscale up
sudo tailscale status
systemctl status sshd tailscaled
```

SSH is key-only on port `2222`. Sunshine is intended to be accessed through
the tailnet; configure its credentials and pair Moonlight clients through its
web UI after Tailscale is connected. Its streaming ports are allowed only on
`tailscale0`. The firewall also allows inbound TCP port `45013` for SimpleX.

### Fingerprint reader

The P52's `06cb:009a` Validity reader uses `open-fprintd` plus
`python-validity`, not the stock libfprint service. Check the backend and
perform enrollment as the user who will authenticate:

```sh
systemctl status open-fprintd python3-validity
fprintd-enroll
fprintd-list "$USER"
fprintd-verify
```

For backend and device logs:

```sh
journalctl -u open-fprintd -u python3-validity -b
journalctl -k -b | grep -iE 'usb|fprint|validity|synaptics'
```

Ly currently uses password authentication; fingerprint authentication remains
enabled for TTY login, sudo, and polkit. This keeps initial graphical login
available even if the fingerprint reader is not enrolled or its backend is
unavailable. Check the generated Ly auth stack with `grep '^auth ' /etc/pam.d/ly`;
it should include `pam_unix.so` and omit `pam_fprintd.so`. If Ly fingerprint
login is enabled later, retain password (`unixAuth`) authentication as a
fallback.

### Media-dependent services

If Syncthing, MPD, or the audio directory setup fails, first confirm `/media`
is mounted. Syncthing and MPD have mount dependencies configured so they do
not intentionally initialize their data on the root filesystem.

## Backups

Btrfs Snapper snapshots cover the root subvolume only; they are not a backup
for `/home` or the separate ext4 `/media` filesystem. Syncthing is also not a
backup because deletions or unwanted changes can propagate. Keep independent,
preferably off-machine backups of important personal, music, and project data.
