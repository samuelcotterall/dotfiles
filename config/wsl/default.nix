# NixOS-WSL specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL

{pkgs, ... }:

{
  imports = [
    # include NixOS-WSL modules
  ];

  wsl = {
    enable = true;
    defaultUser = "nixos";
    nativeSystemd = true;
    interop.includePath = false;
  };

  environment = {
    systemPackages = with pkgs; [
      wslu
    ];
  };
}
