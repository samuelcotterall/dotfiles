{ pkgs, config, lib, inputs, ... }:

{
  imports = [
    ./git.nix
    inputs._1password-shell-plugins.hmModules.default
  ];

  nixpkgs.config.allowUnfree = true;

  home = {

    username = "samuelcotterall";
    homeDirectory = "/Users/samuelcotterall";
    stateVersion = "24.05"; # Please read the comment before changing.

    packages = with pkgs; [
      starship
      zsh-autocomplete
      nodejs_20
      mkcert
      gh
      yarn
      _1password-cli
    ];
  };


  programs._1password-shell-plugins = {
    enable = true;
    plugins = with pkgs; [ gh ];
  };
  programs.home-manager.enable = true;

  programs.zsh = {
      enable = true;
      sessionVariables = {
        OP_PLUGIN_ALIASES_SOURCED = 1;
        GITHUB_TOKEN = "op://Private/Github/token";
      };

      shellAliases = {
        gh = "op plugin run -- gh";
        h2 = "$(npm prefix -s)/node_modules/.bin/shopify hydrogen";
      };
      initExtra = ''
        setopt completealiases
        eval "$(starship init zsh)"
        clear
      '';
    };

}
