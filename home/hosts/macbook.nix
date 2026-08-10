{ config, lib, ... }:

{
  home.username = "jinwoo";
  home.homeDirectory = "/Users/jinwoo";

  programs.git.settings = {
    user = {
      email = "jinwoo.leo.jeong@icloud.com";
      signingKey = "0A7587C476E5B3F4";
    };

    commit.gpgSign = true;
    tag.gpgSign = true;
  };

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

  home.file.".hammerspoon".source = ../../dot_hammerspoon;
}
