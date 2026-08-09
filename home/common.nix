{ pkgs, ... }:

{
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    eza
    ripgrep
    fzf
    gh
    jq
    tmux
    zoxide
  ];

  home.file.".tmux.conf".source = ../tmux.conf;

  programs.home-manager.enable = true;
}
