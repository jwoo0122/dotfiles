{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    hermes-agent.url = "github:NousResearch/hermes-agent";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, hermes-agent, ... }: {
    homeConfigurations = {
      macbook = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-darwin;

        extraSpecialArgs = {
          inherit hermes-agent;
        };

        modules = [
          ./home/common.nix
          ./home/profiles/desktop.nix
          ./home/hosts/macbook.nix 
        ];
      };

      wsl = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;

        extraSpecialArgs = {
          inherit hermes-agent;
        };

        modules = [
          ./home/common.nix
          ./home/hosts/wsl.nix
        ];
      };
    };
  };
}
