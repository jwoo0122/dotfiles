{ pkgs, ... }:

{
  programs.ghostty = {
    enable = true;

    package =
      if pkgs.stdenv.hostPlatform.isDarwin
      then null
      else pkgs.ghostty;

    settings = {
      theme = "GitHub Dark Default";

      font-family = [
        "Hack"
      ];

      font-size = 15;
      cursor-style = "block";
    };
  };

  programs.zed-editor = {
    enable = true;

    mutableUserSettings = false;
    mutableUserKeymaps = false;

    userSettings = builtins.fromJSON (
      builtins.readFile ../../config/zed/settings.json
    );
    
    userKeymaps = [
      {
        bindings = { };
      }
    ];
  };
}
