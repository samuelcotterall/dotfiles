{ pkgs, lib, ... }:

{
  imports = [
    ./git.nix
    ./helix.nix
    ./nvim
    ./starship.nix
    ./tmux.nix
  ];

  xdg.enable = true;
  # TODO: move this to ./home-manager/modules/darwin or something
  xdg.configFile."hammerspoon" = lib.mkIf pkgs.stdenv.isDarwin {
    source = ./../.config/hammerspoon;
  };
  xdg.configFile."kanata" = lib.mkIf pkgs.stdenv.isDarwin {
    source = ./../.config/kanata;
  };
  xdg.configFile."ghostty/config".source = ./../.config/ghostty/config;

  home = {
    stateVersion = "24.05"; # Please read the comment before changing.

    # The home.packages option allows you to install Nix packages into your
    # environment.
    packages = with pkgs; [
      amber
      devenv
      markdown-oxide
      nixd
      ripgrep
      smartcat
    ];

    sessionVariables = {
    };
  };

  programs = {
    fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting # N/A
        bind \cw backward-kill-word
      '';
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    jujutsu = {
      enable = true;
      settings = {
        user = {
          name = "Evan Travers";
          email = "evantravers@gmail.com";
        };
      };
    };
  };

  services.ollama.enable = true;
}
