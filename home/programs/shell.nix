{ pkgs, ... }:

{
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

    initContent = builtins.readFile ../../config/zshrc;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

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

  xdg.configFile."async.zsh".source = ../../config/async.zsh;

  programs.eza = {
    enable = true;
    enableZshIntegration = true;
  };
}
