{ pkgs, lib, ... }:

{
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "claude-code"
    ];

  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    actionlint
    cmake
    eza
    ffmpeg
    ripgrep
    gh
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

  # Claude Code
  programs.claude-code = {
    enable = true;

    settings = builtins.fromJSON (
      builtins.readFile ../dot_claude/private_settings.json
    );
  };
  home.file.".claude/CLAUDE.md".source = ../dot_codex/AGENTS.md;


  # Async zsh configuration
  xdg.configFile."async.zsh".source = ../dot_config/async.zsh;

  # tmux
  programs.tmux = {
    enable = true;
    extraConfig = builtins.readFile ../tmux.conf;
  };

  # git
  programs.git = {
    enable = true;
    
    settings = {
      user.name = "Jinwoo Jeong";
    };
  };
  
  # go
  programs.go = {
    enable = true;
  };

  # pi-coding-agent
  programs.pi-coding-agent = {
    enable = true;

    context = ../dot_codex/AGENTS.md;

    settings = {
      packages = [
        "npm:pi-sub-agent@0.1.5"
      ];
    };

    extraPackages = [
      pkgs.nodejs_24
    ];
  };

  programs.home-manager.enable = true;
}
