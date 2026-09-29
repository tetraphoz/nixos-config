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

The flake also provides a standalone Home Manager output:

```sh
home-manager switch --flake .#tetra
```

Use that only when deploying Home Manager independently. On this machine,
the usual path is `nixos-rebuild`, which applies the integrated Home Manager
configuration together with the system configuration.

## Desktop sessions

XMonad is the default Ly session. Select **Hyprland** in Ly to test the
optional Wayland session and the WiVRn/WayVR desktop path. Its user
configuration is managed by Home Manager. The main bindings are `Super+Return`
for Kitty, `Super+D` for Wofi, `Super+Q` to close a window, and `Super+1`–`5`
to switch workspaces.

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

Ly is configured for fingerprint-only authentication. Keep a working TTY or
other recovery route available when changing the fingerprint/PAM setup.

### Media-dependent services

If Syncthing, MPD, or the audio directory setup fails, first confirm `/media`
is mounted. Syncthing and MPD have mount dependencies configured so they do
not intentionally initialize their data on the root filesystem.

## Backups

Btrfs Snapper snapshots cover the root subvolume only; they are not a backup
for `/home` or the separate ext4 `/media` filesystem. Syncthing is also not a
backup because deletions or unwanted changes can propagate. Keep independent,
preferably off-machine backups of important personal, music, and project data.
