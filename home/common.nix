{ pkgs, lib, hermes-agent, ... }:

{
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "claude-code"
    ];

  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    actionlint
    cmake
    ffmpeg
    jq
    nodejs_24
    pnpm
    tree-sitter
    yarn
    hermes-agent.packages.${pkgs.system}.default
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

    initContent = builtins.readFile ../config/zshrc;
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
  xdg.configFile."nvim".source = ../config/nvim;

  # Codex
  programs.codex = {
    enable = true;
    context = ../config/codex/AGENTS.md;
  };
  home.file."AGENTS.md".source = ../config/codex/AGENTS.md;

  # Claude Code
  programs.claude-code = {
    enable = true;

    settings = builtins.fromJSON (
      builtins.readFile ../config/claude/private_settings.json
    );
  };
  home.file.".claude/CLAUDE.md".source = ../config/codex/AGENTS.md;


  # Async zsh configuration
  xdg.configFile."async.zsh".source = ../config/async.zsh;

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

    context = ../config/codex/AGENTS.md;

    settings = {
      packages = [
        "npm:pi-sub-agent@0.1.5"
      ];
    };

    extraPackages = [
      pkgs.nodejs_24
    ];
  };

  # GitHub CLI
  programs.gh = {
    enable = true;
  };

  # Hermes Agent
  home.file.".hermes/SOUL.md".source = ../config/hermes/private_SOUL.md;

  # mise
  programs.mise = {
    enable = true;
    enableZshIntegration = true;

    globalConfig = {
      tools = {
        "go:github.com/d-kuro/gwq/cmd/gwq" = "latest";
        "npm:agent-browser" = "0.33.2";
      };

      settings = {
        idiomatic_version_file_enable_tools = [ ];
      };
    };
  };

  # eza
  programs.eza = {
    enable = true;
    enableZshIntegration = true;
  };

  # ripgrep
  programs.ripgrep = {
    enable = true;
  };

  # Agent skills
  home.file.".agents/skills".source = ../config/agents/skills;

  # Lucy
  xdg.configFile."lucy/AGENTS.md".source = ../config/codex/AGENTS.md;

  # colortest
  home.file.".local/bin/colortest" = {
    source = ../config/colortest;
    executable = true;
  };

  programs.home-manager.enable = true;
}
