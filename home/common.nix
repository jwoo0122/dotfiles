{ pkgs, ... }:

{
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    actionlint
    cmake
    eza
    ffmpeg
    ripgrep
    fzf
    gh
    go
    jq
    neovim
    nodejs_24
    tmux
    zoxide
    pnpm
    tree-sitter
    yarn
  ];

  home.file.".tmux.conf".source = ../tmux.conf;

  programs.home-manager.enable = true;
}
