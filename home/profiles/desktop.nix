{ pkgs, ... }:

{
  programs.ghostty = {
    enable = true;

    settings = {
      theme = "GitHub Dark Default";

      font-family = [
        "Hack"
      ];

      font-size = 15;
      cursor-style = "block";
    };
  };
}
