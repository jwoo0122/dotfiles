{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    hermes-agent.url = "github:NousResearch/hermes-agent";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, hermes-agent, ... }:
  let
    mkHome = system: modules:
      home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        
        extraSpecialArgs = {
          inherit hermes-agent;
        };

        inherit modules;
      };
  in {
    homeConfigurations = {
      macos = mkHome "aarch64-darwin" [
        ./home/common.nix
        ./home/profiles/desktop.nix
        ./home/hosts/macos.nix
      ];

      work-macos = mkHome "aarch64-darwin" [
        ./home/common.nix
        ./home/profiles/desktop.nix
        ./home/hosts/work-macos.nix
      ]

      wsl = mkHome "x86_64-linux" [
        ./home/common.nix
        ./home/hosts/wsl.nix
      ];
    };
  };
}
