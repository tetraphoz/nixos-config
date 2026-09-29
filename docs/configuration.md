# Configuration map

## Flake and outputs

`flake.nix` pins Nixpkgs and Home Manager to the `26.05` release branches and
adds the `pi.nix` input. It defines:

- `nixosConfigurations.p52` — the NixOS system for the ThinkPad P52.
- `homeConfigurations.tetra` — a standalone Home Manager output. The normal
  setup uses Home Manager as a NixOS module, so a system rebuild applies both
  the OS and user configuration together.
- `formatter.x86_64-linux` — `nixfmt`, used by `nix fmt`.

The flake overlays contain three machine/workflow-specific package adjustments:

- `python-validity` and `open-fprintd-p52` provide the Validity fingerprint
  sensor backend and fix NixOS-incompatible service paths.
- WiVRn is built from the `26.9` upstream release with its matching patched
  Monado source, rather than the version currently used by the pinned Nixpkgs.
- REAPER is pinned to the upstream `7.80` Linux x86_64 archive because the
  pinned Nixpkgs release contains `7.73`.

These overrides have fixed source revisions and hashes. Revisit them when
updating Nixpkgs or when the fixes/releases are available upstream. The REAPER
override is specific to this flake's `x86_64-linux` system.

## Module map

`hosts/p52/configuration.nix` is the host entry point. It imports the generated
hardware file and the feature modules below.

| File | Responsibility |
| --- | --- |
| `hardware-configuration.nix` | LUKS, Btrfs/ext4 filesystems, EFI, and swap generated for this machine. |
| `desktop.nix` | X11, XMonad (the default Ly session), Ly login manager, autorandr, Thunar, fonts, OBS, and desktop support. |
| `hyprland.nix` | Enables the optional Hyprland Wayland session and Xwayland; the user session configuration is managed from Home Manager. |
| `nvidia.nix` | Quadro P2000 driver and Intel/NVIDIA PRIME configuration, including reverse PRIME for the HDMI output. |
| `power.nix` | Intel microcode, zram, TLP, Btrfs scrubbing, and Snapper root snapshots. |
| `development.nix` | System-wide developer tools, including Nix workflow/lint tools, plus direnv. |
| `emacs.nix` | Doom Emacs dependencies, language servers, formatters, and language tooling. |
| `networking.nix` | NetworkManager, Tailscale, firewall rules, SSH, Bluetooth, and network diagnostics. |
| `services.nix` | Printing, firmware updates, Sunshine, Validity fingerprint services, Syncthing, and ThinkPad fan control. |
| `containers.nix` | Docker, Podman tools, libvirt, QEMU, and virt-manager. |
| `audio.nix` | PipeWire, JACK/PulseAudio/ALSA compatibility, realtime limits, and audio controls. |
| `music-production.nix` | DAWs, instruments, plug-ins, Windows plug-in support, and the `/media/audio` directory layout. |
| `games.nix` | Steam, GameMode, MangoHud, Proton utilities, and Prism Launcher. |
| `vr.nix` | WiVRn, Steam OpenXR runtime integration, and WayVR. |

`home/tetra.nix` manages user applications and settings: shell, Git, desktop
applications, MPD, XMonad-related links, Kitty, and other dotfiles. It also
installs Wayland utilities and writes the Hyprland configuration; XMonad
remains the default login session. The application configurations themselves
are under `dotfiles/`.

## Hardware and storage notes

The generated hardware configuration mounts an encrypted Btrfs device as
separate subvolumes for `/`, `/home`, and `/nix`; `/.snapshots` is a separate
Btrfs subvolume. `/boot` is EFI and `/media` is a separate ext4 filesystem.
Avoid editing `hardware-configuration.nix` by hand unless you intend to own
those machine-specific changes; NixOS may regenerate it.

Snapper is configured for `/` only. Its snapshots do not back up the separate
`/home` or `/media` filesystems. Syncthing synchronizes data but is not a
backup. In particular, music and audio-production data under `/media` need an
independent backup plan.

Several services depend on `/media` being mounted:

- Syncthing stores its data under `/media/syncthing`.
- MPD reads `/media/music`.
- The audio-library setup service creates project, sample, plug-in, and preset
  directories under `/media/audio`.

The setup exposes user plug-ins from `/media/audio` alongside Nix-managed
plug-ins. Home Manager sets the corresponding VST, VST3, CLAP, LV2, LADSPA,
and DSSI search paths.

## Access and security behavior

- SSH listens on TCP port `2222`; password and keyboard-interactive
  authentication are disabled. Ensure an authorized public key is installed
  before relying on remote SSH access.
- TCP port `45013` is allowed through the host firewall for SimpleX.
- Sunshine's streaming ports are allowed on `tailscale0`, not generally on
  LAN/public interfaces. Tailscale must be authenticated after initial setup.
- The Ly PAM stack is configured for fingerprint-only login. Password login
  remains available through other configured PAM services such as TTY login
  and sudo. The fingerprint backend is a custom Validity stack rather than the
  stock `libfprint` driver.
- Membership in the `docker` group grants root-equivalent access to the host.
