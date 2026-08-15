{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Version control
    git
    gh

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
    pyright
    #pipx

    #nodejs
    #npm
    typescript

    php
    phpPackages.composer

    jdk17
    kotlin

    # Ai
    aider-chat

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

  programs.git = {
    enable = true;

    config = {
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };
}
