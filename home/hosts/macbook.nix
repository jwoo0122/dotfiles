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
    ]
  }
}
