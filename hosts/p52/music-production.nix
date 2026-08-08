{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [

    #
    # DAWs
    #
    ardour
    renoise

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
    surge-XT
    yoshimi
    zynaddsubfx
    cardinal
    bespokesynth

    #
    # Samplers
    #
    sfizz

    #
    # Plugins
    #
    calf
    lsp-plugins
    zam-plugins
    x42-plugins
    dragonfly-reverb

    #
    # Audio editing
    #
    audacity

    #
    # Analysis
    #
    sonic-visualiser

    #
    # MIDI / routing
    #
    patchage

    #
    # Experimental audio
    #
    puredata
    supercollider
    csound
  ];
}
