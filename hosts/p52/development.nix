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

    # Build tools
    gcc
    clang
    llvm
    gnumake
    cmake
    ninja
    pkg-config

    # Languages
    rustup
    rust-analyzer

    python3
    uv
    pipx

    nodejs
    nodePackages.npm
    nodePackages.typescript

    php
    phpPackages.composer

    jdk17
    kotlin

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
  ];

  programs.git = {
    enable = true;

    config = {
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };
}
