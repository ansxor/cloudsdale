{
  description = "Home server configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    sops-nix.url = "github:Mic92/sops-nix";
    jellyfin-media-adder.url = "path:./repos/jellyfin-media-adder";
  };

  outputs = { self, nixpkgs, sops-nix, jellyfin-media-adder, ... }@inputs: 
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {inherit system;};
  in
  {
    nixosModules.sbs2 = import ./modules/sbs2.nix;

    packages.${system} = {
      contentapi = pkgs.callPackage ./packages/contentapi.nix {};
      jellyfin-media-adder = jellyfin-media-adder.defaultPackage.${system};
    };

    nixosConfigurations.Cloudsdale = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit inputs;
	localPkgs = self.packages.${system};
      };
      modules = [
        ./configuration.nix

        self.nixosModules.sbs2
	{
	  sbs2 = {
	    apiDomain = "content.shy.home.arpa";
	    apiSecure = false;
	  };
	}

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
