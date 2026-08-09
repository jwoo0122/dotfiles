{
  home.username = "leo";
  home.homeDirectory = "/home/leo";

  programs.git.settings = {
    user.email = "mail@jinwoojeo.ng";

    credential."https://github.com".helper = [
      ""
      "!/usr/bin/gh auth git-credential"
    ];

    credential."https://gist.github.com".helper = [
      ""
      "!/usr/bin/gh auth git-credential"
    ];
  };
}
