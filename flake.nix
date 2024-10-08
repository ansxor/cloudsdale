{
  description = "Home server configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    sops-nix.url = "github:Mic92/sops-nix";
    jellyfin-media-adder.url = "git+http://git.shy.home.arpa/answer/jellyfin-media-adder.git?rev=d7b53fa67b0e656a2489f3b9efb442bedd5569a4";
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
      jellyfin-media-adder = jellyfin-media-adder.packages.${system}.default;
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
	./modules/jellyfin-media-adder.nix

	./services/gitea.nix
	./services/jellyfin.nix
	./services/samba.nix
	./services/caddy.nix
	./services/contentapi.nix
	./services/jellyfin-media-adder.nix

	sops-nix.nixosModules.sops
      ];
    };
  };
}
