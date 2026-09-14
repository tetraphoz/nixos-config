{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    emacs

    # Doom dependencies
    git
    ripgrep
    fd
    gcc
    clang
    cmake
    gnumake
    nodejs
    python3
    libtool
    pkg-config
    libvterm
    tree-sitter

    # LSP servers used by the enabled Doom language modules
    clang-tools # clangd
    basedpyright
    python3Packages.debugpy
    python3Packages.pytest
    pipenv
    gopls
    rust-analyzer
    jdt-language-server
    typescript-language-server
    vscode-langservers-extracted # HTML, CSS and JSON
    yaml-language-server
    dockerfile-language-server
    nil
    bash-language-server
    tuntox
    dockfmt
    terraform
    fish-lsp
    terraform-ls
    texlab
    kotlin-language-server
    clojure-lsp
    beancount-language-server
    haskell-language-server
    intelephense
    phpactor
    omnisharp-roslyn

    # Formatters and language tooling used by +format and project modes
    black
    ruff
    prettier
    shfmt
    shellcheck
    nixfmt
    rustfmt
    cljfmt
    csharpier
    ktlint
    platformio

    # Debugging, grammar checking and spelling
    gdb
    lldb
    languagetool
    enchant
    aspell
    aspellDicts.en
    aspellDicts.es

    # Lisp and language runtimes used by the enabled Doom modules
    sbcl
    clisp
    clojure
    beancount
    ledger
    racket
    cabal-install
    fourmolu
    hlint
    gomodifytags
    gotests
    gore
    jdk17
    dotnet-sdk
    php

    # Org, document and auxiliary tools
    pandoc
    graphviz
    poppler-utils
    calibre
    w3m
    html-tidy
    stylelint
    js-beautify
    libxml2 # xmllint
    xdotool
    xwininfo
    # A compact TeX toolchain for the enabled LaTeX module; projects can
    # provide additional packages through their own flakes.
    texlive.combined.scheme-small
    direnv
  ];

}
