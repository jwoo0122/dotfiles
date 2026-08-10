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

  programs.zed-editor = {
    enable = true;

    mutableUserSettings = false;
    mutableUserKeymaps = false;

    userSettings = builtins.fromJSON (
      builtins.readFile ../../config/zed/private_settings.json
    );
    
    userKeymaps = [
      {
        bindings = { };
      }
    ];
  };
}
