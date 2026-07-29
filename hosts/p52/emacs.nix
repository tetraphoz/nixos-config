{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    emacs

    # Doom dependencies
    git
    ripgrep
    fd
    clang
    nodejs
    python3

    # Lisp tooling
    sbcl
    clisp

    # Org / documents
    pandoc
    graphviz

    # Spell checking
    aspell
    aspellDicts.en
    aspellDicts.es
  ];


  services.emacs = {
    enable = true;

    package = pkgs.emacs;
  };


  environment.variables = {
    EDITOR = "emacsclient";
    VISUAL = "emacsclient";
  };
}
