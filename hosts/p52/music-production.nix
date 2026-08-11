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

    #
    # Samplers
    #
    sfizz

    #
    # Effects / Plugins
    #
    calf
    lsp-plugins
    zam-plugins
    x42-plugins
    dragonfly-reverb

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
}
