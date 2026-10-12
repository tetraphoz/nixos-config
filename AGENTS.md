# Repository guidance

## Purpose and layout

This is tetra's live NixOS and Home Manager configuration for a ThinkPad P52
(`x86_64-linux`), not a generic dotfiles template. Work from `/etc/nixos`.

Read `README.org` and the relevant parts of `docs/configuration.md` and
`docs/operations.md` before changing system behavior. Treat the actual modules
and `flake.lock` as authoritative if documentation is out of date.

- `flake.nix`: inputs, package overlays, formatter, and configuration outputs.
- `flake.lock`: pinned dependencies; change only for an intentional dependency update.
- `hosts/p52/configuration.nix`: host entry point; feature-specific system
  settings belong in the neighboring modules.
- `hosts/p52/hardware-configuration.nix`: generated, machine-specific storage
  and hardware settings; avoid edits unless the task specifically requires them.
- `home/tetra.nix`: shared user configuration, application links, and Pi setup.
- `home/xmonad.nix` and `home/hyprland.nix`: session-specific packages and file wiring.
- `dotfiles/`: application configuration and desktop helper scripts.
- `dotfiles/doom.d/`: Doom modules (`init.el`), packages (`packages.el`), and
  behavior (`config.el`); avoid incidental edits to `custom.el`.
- `dotfiles/pi/`: agent definitions and local extension, prompt, and skill
  sources; consult its `README.md` when changing their wiring.
- `dotfiles/hypr/README.md`: desktop helper and workspace behavior.
- `docs/`: configuration map and operational procedures; keep relevant docs in
  sync with user-visible changes.

## Configuration invariants

- The system output is `nixosConfigurations.p52`; the standalone Home Manager
  output is `homeConfigurations.tetra`.
- Home Manager is normally integrated into NixOS. Both outputs import the
  shared, XMonad, and Hyprland home modules; keep them aligned.
- XMonad is the default Ly session. Hyprland is an optional session used for
  the WiVRn/WayVR path; do not replace one with the other unintentionally.
- Hyprland's workspace helpers are output-agnostic. Physical monitor settings
  are mutable in `~/.config/hypr/monitors.conf`, managed by `nwg-displays`;
  headless `VR-*` outputs are runtime-only. Preserve these boundaries.
- The fingerprint overlays implement the P52's Validity reader, not ordinary
  libfprint support. WiVRn and its patched Monado sources must stay compatible.
  Update overridden versions, URLs/revisions, and fixed hashes together.
- Do not bump `system.stateVersion` or `home.stateVersion` as part of ordinary
  package/input upgrades; those values control migration compatibility.
- Preserve key-only SSH, Sunshine's Tailscale-only firewall exposure, and
  password fallback for authentication unless explicitly changing those policies.
- `/media` is a separate filesystem used by music/audio and synchronization
  services. Preserve mount dependencies; root snapshots do not back up this data.

## Editing practices

- Inspect `git status --short` and the relevant diff first. This working tree
  may contain unrelated, in-progress changes; preserve both staged and unstaged work.
- Make small, focused edits in the owning module. Follow neighboring Nix,
  Emacs Lisp, Haskell, and application-config conventions.
- Format only changed Nix files with the flake's `nixfmt`; avoid repository-wide
  reformatting or automatic lint fixes that touch unrelated work.
- Add packages and persistent settings declaratively, rather than installing
  them into ad hoc user profiles or editing generated files.
- Edit source files here, not Home Manager links under `~/.config`, `~/.doom.d`,
  or `~/.pi`, and never edit `/nix/store` contents. Check symlink targets first.
- `dotfiles/dunst/dunstrc` and `dotfiles/xmonad/lib/Colors.hs` point into the
  user's Pywal cache. Change templates under `dotfiles/wal/templates/` or the
  generating configuration, not the cache through those links. Preserve symlinks.
- New dotfiles and helpers may also need `home.file`/`xdg.configFile` wiring
  and executable flags. Keep writable runtime files outside store-backed trees.
- Bash helpers should quote variables, handle missing tools/session state,
  and retain the existing safeguards around output/window changes.
- Never include credentials, private keys, authentication databases, or private
  service state in the repository.

## Validation

There is no conventional application test suite. Choose checks for the files
changed and report exactly what ran. Documentation-only changes do not require
a NixOS build.

Check formatting of the changed Nix files (replace the example paths as needed):

```bash
nixfmt --check flake.nix home/tetra.nix
```

For Nix changes, validate the flake and evaluate the system build plan without
changing dependency pins:

```bash
nix flake check --no-update-lock-file && nix build .#nixosConfigurations.p52.config.system.build.toplevel --dry-run --no-update-lock-file
```

When changing Home Manager wiring, also evaluate its standalone activation:

```bash
nix build .#homeConfigurations.tetra.activationPackage --dry-run --no-update-lock-file
```

Check changed shell scripts without executing desktop actions:

```bash
bash -n dotfiles/hypr/workspace && bash -n dotfiles/xinitrc
```

Use `statix`, `deadnix`, and ShellCheck when relevant and available; distinguish
pre-existing findings from new ones. Inspect the final diff and whitespace.
A dry run is not a successful build, and a successful build does not verify a
live graphical session. Report network, cache, evaluation, or runtime limits.

Git-backed flakes omit untracked files. If a new imported module/resource is
missing during evaluation, check tracking before diagnosing it as a Nix error;
do not stage the user's work without permission.

## Live-system safety

Evaluation and builds are distinct from activation. Do not run
`nixos-rebuild test`, `switch`, or `boot`, Home Manager activation, service
restarts, compositor reloads, or Doom synchronization unless requested.
`test` also changes the running system; it is not a passive check.

Do not update flake inputs, collect garbage, delete generations, alter disks,
reset the fingerprint reader, enroll credentials, or change network access as
an incidental repair. Explain proposed live changes and use the procedures in
`docs/operations.md` when the user authorizes them.
