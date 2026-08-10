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

  home.sessionVariables = {
    EDITOR = "nvim";
    LUCY_GREETING_IMAGE = "false";
  };

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.cargo/bin"
  ];

  programs.home-manager.enable = true;
}
