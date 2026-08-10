{ config, lib, ... }:

{
  programs.ghostty = {
    package = null;

    settings.font-family = lib.mkForce [
      "Hack"
      "Apple SD Gothic Neo"
    ];
  };

  launchd.agents.hermes-gateway = {
    enable = true;

    config = {
      Label = "ai.hermes.gateway";

      ProgramArguments = [
        "${config.home.profileDirectory}/bin/hermes"
        "gateway"
        "run"
        "--replace"
      ];

      RunAtLoad = true;
      KeepAlive = true;

      StandardOutPath = "/tmp/hermes-gateway.out.log";
      StandardErrorPath = "/tmp/hermes-gateway.err.log";
    };
  };

  home.file.".hammerspoon/init.lua".source = ../../config/hammerspoon/init.lua;
}
