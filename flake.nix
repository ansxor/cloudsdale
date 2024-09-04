{
  description = "Home server configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs = { self, nixpkgs, sops-nix, ... }@inputs: {
    localPackages = {
      contentapi = import ./packages/contentapi.nix { inherit pkgs; };
    };

    nixosConfigurations.Cloudsdale = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix

	./services/gitea.nix
	./services/jellyfin.nix
	./services/samba.nix
	./services/nginx.nix

	sops-nix.nixosModules.sops
      ];
    };
  };
}
