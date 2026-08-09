{ pkgs, ... };

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

  programs.home-manager.enable = true;
}
