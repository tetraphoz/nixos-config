# Hyprland + VR desktop — progress

Hyprland is an optional Wayland session alongside XMonad/Xmobar; XMonad stays
the Ly default. This profile is intended to work in several modes, not just the
currently docked P52 layout: laptop panel alone, dock/projector, and a Quest 3
session with runtime virtual screens. Keep workspace and bar configuration
independent of a fixed connector count.

## Current design

- Physical monitor modes and geometry stay in the mutable
  `~/.config/hypr/monitors.conf` managed by `nwg-displays`. A generic monitor
  fallback in `hyprland.conf` covers outputs not explicitly listed there.
- Workspace IDs are globally unique in Hyprland. The config no longer pins
  numeric workspace ranges to `DP-3` or `eDP-1`; local navigation and number
  slots use the currently focused output. A helper allocates a free global ID
  on that output when a new workspace is requested.
- Output focus can cycle through Hyprland's current monitor list or move
  spatially. Window-transfer bindings are relative to adjacent outputs, not
  named connectors.
- `hypr-virtual-output` creates/configures/removes runtime headless outputs
  with `hyprctl output create headless`. It defaults to 1920x1080@60 and scale
  1; users can select a mode per output. It only manages `VR-*` names and does
  not persist unused virtual displays. Removing a populated output warns that
  Hyprland will migrate its workspace windows and requires confirmation.
- Waybar is configured per output (`all-outputs: false`) without a static
  persistent-workspace list, so bars/workspace buttons can follow additional
  outputs.
- No new workspace rules have been reloaded into the running session, and no
  headless display has been created. Live workspace/window movement is still
  pending explicit runtime testing.

## XR / virtual-display research (2026-09-30)

### Breezy Desktop

Reviewed the upstream [Breezy Desktop README](https://github.com/wheaney/breezy-desktop/tree/v2.12.2)
and the [Quest 3 compatibility question (#137)](https://github.com/wheaney/breezy-desktop/issues/137).

- Breezy Desktop v2.12.2 supports multiple virtual and physical monitors, but
  its desktop integration targets KDE Plasma 6 or GNOME 45–51, and its device
  path is for supported XR glasses through
  [XRLinuxDriver](https://github.com/wheaney/XRLinuxDriver#supported-devices).
- The maintainer answered the Quest 3 question directly: Quest support would
  require a substantially different integration and is not currently
  supported; the response points Quest users toward VR-oriented overlays.
  Quest 3 is not listed as a supported glasses device in XRLinuxDriver.
- Breezy Vulkan is an XR-glasses/Vulkan application layer, not a general
  Quest desktop-streaming or Hyprland virtual-output solution.
- **Decision:** Breezy's multi-display features are interesting, but it is not
  the fit for this Hyprland + WiVRn + Quest 3 setup. Do not add it to the Nix
  profile unless the headset/compositor requirements change.

### WiVRn and WayVR

Reviewed the [WayVR upstream README](https://github.com/wayvr-org/wayvr) and
[configuration guide](https://wayvr.org/docs/basics/configuration/).

- WayVR is an OpenXR/OpenVR overlay that captures existing Wayland/X11 desktop
  screens and can launch apps. It is already configured as WiVRn's application.
- On first use, its screen-share portal asks the user to select the screens in
  a requested order. If the wrong screens were authorized, WayVR documents
  clearing PipeWire tokens and restarting the software.
- WayVR provides VR overlays/capture; it does not create Hyprland monitor
  outputs. Headless output creation and WayVR screen capture are separate
  operations. Create the desired Hyprland outputs before starting/restarting
  WayVR, then authorize/select them in the portal.
- Whether this host's WayVR/portal stack captures and tracks multiple Hyprland
  headless outputs correctly must be verified live.

### Hyprland output and workspace behavior

The host pins Hyprland 0.55.4. In its
[versioned source](https://github.com/hyprwm/Hyprland/tree/v0.55.4):

- [`hyprctl output create headless NAME` / `output destroy NAME`](https://github.com/hyprwm/Hyprland/blob/v0.55.4/src/debug/HyprCtl.cpp#L1734-L1784)
  uses user-created outputs from the headless backend. The helper wraps this
  runtime API and applies the requested `monitor` mode/scale rule.
- [`m+N` / `m-N` and `m~N`](https://github.com/hyprwm/Hyprland/blob/v0.55.4/src/helpers/MiscFunctions.cpp#L375-L448)
  navigate existing workspaces on the focused monitor; `e` is the all-monitor
  variant. The `m~N` form is one-based local indexing. Workspace IDs themselves
  remain global/unique.
- [Creating a workspace by ID](https://github.com/hyprwm/Hyprland/blob/v0.55.4/src/config/shared/actions/ConfigActions.cpp#L973-L1023)
  associates a new workspace with the focused monitor. Monitor `+N`/`-N`
  selectors cycle through the current output list; `l/r/u/d` selectors are
  spatial. This supports a variable monitor count without workspace rules that
  mention specific connector names.
- The [monitor rules guide](https://wiki.hypr.land/Configuring/Monitors/) documents
  the empty-selector fallback and automatic placement for otherwise unknown
  outputs. Hyprland also documents that removing/disabling a monitor migrates
  its workspaces/windows to outputs that remain, so output removal is treated
  as a potentially disruptive action.

## This pass

- [x] Research Breezy Desktop against the actual Quest 3 + Hyprland use case;
  recorded source links and the compatibility decision above.
- [x] Replace the proposed fixed DP-3/eDP-1 workspace split with output-local
  navigation and dynamically allocated workspace IDs.
- [x] Add monitor focus/window-transfer bindings that operate on any output.
- [x] Add generic monitor fallback and remove connector-specific Waybar
  persistent-workspace lists.
- [x] Add helpers for new workspaces and runtime `VR-*` headless outputs.
- [x] Document setup, commands, keybindings, sources, and runtime caveats in
  `dotfiles/hypr/README.md` and the repo operations/configuration docs.
- [x] Run static validation after this refactor.
- [ ] Validate output creation, workspace behavior, and WayVR screen capture
  in a live session; do not create/remove outputs during a session with
  important workspaces/windows until a safe test plan is in place.

## Existing Hyprland work

- [x] Add screenshot/OCR helper; route Print and Ctrl+Print through it.
- [x] Move terminal/music scratchpads and expose overview to Pyprland IPC.
- [x] Add hyprsunset local-time profiles, hyprpicker, and SwayOSD.
- [x] Add the shared Home Manager Polkit launcher to both graphical sessions.
- [x] Keep XMonad/Xmobar as the default Ly session.

## Validation and remaining tests

After this refactor, `Hyprland --verify-config` accepts the generic monitor
fallback and monitor-local bindings. Waybar JSON parses; both new shell helpers
pass `bash -n` and ShellCheck, and mocked IPC tests cover new workspace ID
allocation plus headless-output add/remove/mode setup, including confirmation
before removing a populated virtual output. `nixfmt --check` accepts
`home/hyprland.nix`; `git diff --check` passes; the NixOS system derivation
evaluates and its `--dry-run` includes the updated Home Manager and Waybar
outputs. Earlier checks for Pyprland TOML/plugins and existing helpers remain
valid. No actual NixOS activation or live headless-output operation was run.

Remaining live tests:

1. Test workspace creation, output-local cycling, local number slots, monitor
   focus cycling, spatial focus, and moving a window across outputs with one,
   two, and three outputs. Confirm empty-workspace cleanup matches expectations.
2. With the laptop on `eDP-1` only, create one headless output at 1920x1080@60;
   verify its mode, automatic placement, per-output Waybar, and Hyprland
   workspace allocation. Repeat with a second output and a lower-resolution
   projector/dock combination.
3. Start WiVRn/WayVR only after outputs are present. Approve each desired screen
   in the PipeWire portal, check screen identity/order, mouse mapping, and
   WayVR's response to output creation/removal/resolution changes. Restart or
   clear WayVR PipeWire tokens if selection is stale.
4. Measure Quest streaming/rendering performance with one then multiple virtual
   outputs. Begin at 1080p60; higher resolutions increase capture/render load.
5. Document observed connector names, output modes, focus ordering, and any
   WayVR/portal limitations here and in `dotfiles/hypr/README.md`.

The editor swap file `.hyprland.conf.swp` is user/editor state; do not edit,
remove, or add it to the configuration.
