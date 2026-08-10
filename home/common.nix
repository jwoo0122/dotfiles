{ lib, ... }:

{
  imports = [
    ./programs/shell.nix
    ./programs/dev.nix
    ./programs/agents.nix
  ];
  
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "claude-code"
    ];

  home.stateVersion = "26.05";

  programs.home-manager.enable = true;
}
