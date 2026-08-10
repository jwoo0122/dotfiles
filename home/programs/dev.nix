{ pkgs, ... }:

{
  home.packages = with pkgs; [
    actionlint
    cmake
    ffmpeg
    jq
    nodejs_24
    pnpm
    tree-sitter
    yarn
  ];

  programs.git = {
    enable = true;
    settings.user.name = "Jinwoo Jeong";
  };

  programs.gh.enable = true;
  programs.go.enable = true;
  programs.ripgrep.enable = true;

  programs.neovim.enable = true;
  xdg.configFile."nvim".source = ../../config/nvim;

  programs.tmux = {
    enable = true;
    extraConfig = builtins.readFile ../../tmux.conf;
  };

  home.file.".local/bin/colortest" = {
    source = ../../config/colortest;
    executable = true;
  };
}
