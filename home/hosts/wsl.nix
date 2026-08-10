{ config, ... }:

{
  home.username = "leo";
  home.homeDirectory = "/home/leo";

  programs.git.settings = {
    user.email = "mail@jinwoojeo.ng";
  };

  systemd.user.services.hermes-gateway = {
    Unit = {
      Description = "Hermes Agent Gateway";
      After = [ "network-online.target" ];
    };

    Service = {
      ExecStart = "${config.home.profileDirectory}/bin/hermes gateway run";
      Restart = "on-failure";
      RestartSec = 5;
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
