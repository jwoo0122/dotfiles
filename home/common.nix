{ pkgs, ... }:

{
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    actionlint
    cmake
    eza
    ffmpeg
    ripgrep
    gh
    go
    jq
    nodejs_24
    tmux
    pnpm
    tree-sitter
    yarn
  ];

  programs.zsh = {
    enable = true;

    plugins = [
      {
        name = "zsh-autosuggestions";
        src = pkgs.zsh-autosuggestions;
        file = "share/zsh-autosuggestions/zsh-autosuggestions.zsh";
      }
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.zsh-syntax-highlighting;
        file = "share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
      }
    ];

    initContent = builtins.readFile ../dot_zshrc;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.neovim = {
    enable = true;
  };

  xdg.configFile."nvim".source = ../dot_config/nvim;
  xdg.configFile."async.zsh".source = ../dot_config/async.zsh;

  home.file.".tmux.conf".source = ../tmux.conf;

  programs.home-manager.enable = true;
}
