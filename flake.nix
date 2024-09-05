{
  description = "Home server configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs = { self, nixpkgs, sops-nix, ... }@inputs: 
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {inherit system;};
  in
  {
    packages.${system} = {
      contentapi = pkgs.callPackage ./packages/contentapi.nix {};
    };

    nixosConfigurations.Cloudsdale = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit inputs;
	localPkgs = self.packages.${system};
      };
      modules = [
        ./configuration.nix

	./packages/modules/services/contentapi.nix

	./services/gitea.nix
	./services/jellyfin.nix
	./services/samba.nix
	./services/nginx.nix
	./services/contentapi.nix

	sops-nix.nixosModules.sops
      ];
    };
  };
}
