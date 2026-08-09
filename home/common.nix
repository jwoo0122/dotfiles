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

  # Neovim
  programs.neovim = {
    enable = true;
  };
  xdg.configFile."nvim".source = ../dot_config/nvim;

  # Codex
  programs.codex = {
    enable = true;
    context = ../dot_codex/AGENTS.md;
  };
  home.file."AGENTS.md".source = ../dot_codex/AGENTS.md;

  # Async zsh configuration
  xdg.configFile."async.zsh".source = ../dot_config/async.zsh;

  # tmux
  programs.tmux = {
    enable = true;
    extraConfig = builtins.readFile ../tmux.conf;
  };

  programs.home-manager.enable = true;
}
