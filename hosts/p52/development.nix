{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Version control
    git
    git-lfs
    gh
    lazygit
    delta

    # Shell utilities
    ripgrep
    fd
    fzf
    bat
    eza
    tree
    jq
    yq
    zoxide
    yazi
    plocate
    ncdu
    dust
    duf
    procs
    ouch
    hyperfine
    watchexec
    xh
    just

    # Build tools
    gcc
    clang
    llvm
    gnumake
    cmake
    ninja
    pkg-config
    libtool

    # Languages
    rustup
    rust-analyzer

    python3
    uv
    basedpyright
    #pipx

    #nodejs
    #npm
    typescript

    php
    phpPackages.composer

    go
    gopls
    nil
    gnuplot
    pre-commit

    jdk17
    kotlin
    android-studio
    android-tools

    # Ai
    aider-chat
    pi-coding-agent

    # Databases
    sqlite
    postgresql

    # Networking
    curl
    wget
    openssh
    nmap

    # Documentation
    man-pages
    man-pages-posix
    pandoc

    # Language servers
    ccls
  ];

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

}
