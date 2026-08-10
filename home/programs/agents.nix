{ pkgs, hermes-agent, ... }:

{

  home.packages = [
    hermes-agent.packages.${pkgs.system}.default
  ];

  programs.codex = {
    enable = true;
    context = ../../config/codex/AGENTS.md;
  };
  home.file."AGENTS.md".source = ../../config/codex/AGENTS.md;

  programs.claude-code = {
    enable = true;

    settings = builtins.fromJSON (
      builtins.readFile ../../config/claude/settings.json
    );
  };
  home.file.".claude/CLAUDE.md".source = ../../config/codex/AGENTS.md;

  programs.pi-coding-agent = {
    enable = true;

    context = ../../config/codex/AGENTS.md;

    settings = {
      packages = [
        "npm:pi-sub-agent@0.1.5"
      ];
    };

    extraPackages = [
      pkgs.nodejs_24
    ];
  };

  home.file.".hermes/SOUL.md".source = ../../config/hermes/SOUL.md;

  home.file.".agents/skills".source = ../../config/agents/skills;

  xdg.configFile."lucy/AGENTS.md".source = ../../config/codex/AGENTS.md;
}
