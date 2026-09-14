{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [

    #
    # DAWs
    #
    ardour
    reaper

    #
    # Drum machines
    #
    hydrogen

    #
    # Guitar
    #
    guitarix

    #
    # Synths
    #
    surge-xt
    yoshimi
    zynaddsubfx
    cardinal
    bespokesynth
    vital
    dexed
    helm
    odin2
    synthv1
    samplv1
    drumkv1
    geonkick
    setbfree

    #
    # Samplers
    #
    sfizz
    decent-sampler
    pluginval

    # Free sample libraries
    soundfont-fluid
    soundfont-generaluser-gs
    soundfont-ydp-grand

    #
    # Effects / Plugins
    #
    calf
    lsp-plugins
    zam-plugins
    x42-plugins
    distrho-ports
    airwindows-lv2
    swh_lv2
    mda_lv2
    dragonfly-reverb
    guitarix-vst
    neural-amp-modeler-lv2

    #
    # Windows VST compatibility
    #
    yabridge
    yabridgectl
    wineWow64Packages.stable

    #
    # Routing / JACK / PipeWire
    #
    crosspipe
    qpwgraph
    patchage
    carla

    #
    # Analysis / Editing
    #
    audacity
    sonic-visualiser

    #
    # Experimental / DSP
    #
    puredata
    supercollider
    csound
  ];

  # Keep user-installed projects, samples, presets and plug-ins separate from
  # the Nix-managed system plug-ins.  The media filesystem is mounted before
  # this service runs, so these paths are available to Ardour, Reaper and
  # yabridge after boot.
  systemd.services.audio-library-setup = {
    description = "Create the audio production library layout";
    wantedBy = [ "multi-user.target" ];
    unitConfig.RequiresMountsFor = [ "/media" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      install -d -o tetra -g users -m 0775 \
        /media/audio \
        /media/audio/projects \
        /media/audio/projects/ardour \
        /media/audio/projects/reaper \
        /media/audio/recordings \
        /media/audio/renders \
        /media/audio/stems \
        /media/audio/midi \
        /media/audio/samples \
        /media/audio/samples/drums \
        /media/audio/samples/field-recordings \
        /media/audio/samples/instruments \
        /media/audio/samples/loops \
        /media/audio/samples/one-shots \
        /media/audio/samples/sfz \
        /media/audio/samples/soundfonts \
        /media/audio/presets \
        /media/audio/presets/cardinal \
        /media/audio/presets/dexed \
        /media/audio/presets/surge-xt \
        /media/audio/presets/vital \
        /media/audio/impulse-responses \
        /media/audio/vst \
        /media/audio/vst3 \
        /media/audio/clap \
        /media/audio/lv2 \
        /media/audio/ladspa \
        /media/audio/dssi \
        /media/audio/vst-windows

      # Keep redistributable factory soundfonts visible in one predictable
      # location without copying them out of the Nix store.
      ln -sfn ${pkgs.soundfont-fluid}/share/soundfonts/FluidR3_GM2-2.sf2 \
        /media/audio/samples/soundfonts/FluidR3_GM2-2.sf2
      ln -sfn ${pkgs.soundfont-generaluser-gs}/share/soundfonts/GeneralUser-GS.sf2 \
        /media/audio/samples/soundfonts/GeneralUser-GS.sf2
      ln -sfn ${pkgs.soundfont-ydp-grand}/share/soundfonts/YDP-GrandPiano.sf2 \
        /media/audio/samples/soundfonts/YDP-GrandPiano.sf2

      if [ ! -e /media/audio/README.md ]; then
        cat > /media/audio/README.md <<'EOF'
# Audio library

- `projects/` — Ardour and Reaper sessions
- `recordings/` — raw takes and field recordings
- `samples/` — drums, loops, one-shots, instruments and soundfonts
- `presets/` — synth and effect presets
- `renders/` and `stems/` — exported audio
- `impulse-responses/` — cabinet, room and convolution responses
- `vst-windows/` — Windows VST2/VST3 plug-ins for yabridge
- `vst/`, `vst3/`, `clap/`, `lv2/` — user-installed Linux plug-ins

Nix-managed plug-ins are available through `/run/current-system/sw/lib` and
are included in the VST/LV2/CLAP environment paths.

For Windows plug-ins:

    yabridgectl add /media/audio/vst-windows
    yabridgectl sync
EOF
        chown tetra:users /media/audio/README.md
      fi
    '';
  };
}
