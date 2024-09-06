{ config, pkgs, lib, ... }:

let
  repoUrl = "https://github.com/12Me21/sbs2.git";
  repo = pkgs.fetchFromGitHub {
    owner = "12Me21";
    repo = "sbs2";
    rev = "43d5703b8dda066420b3f41d7ac33da53c9de966";
    sha256 = "sha256-1LllOM7NHksjVtYMaMypn7PT6CQzcn78ub0pWRkx3Uc=";
    fetchSubmodules = true;
    deepClone = true;
    leaveDotGit = true;
  };
  gitPath = lib.replaceStrings ["/"] ["\\/"] "${pkgs.git}/bin/git";
  cfg = config.sbs2;
in
{
  options.sbs2.outputDir = lib.mkOption {
    type = lib.types.path;
    default = "/var/www/sbs2";
    description = "Directory where SBS2 build files will be put.";
  };

  options.sbs2.apiDomain = lib.mkOption {
    type = lib.types.str;
    default = "qcs.shsbs.xyz";
    description = "Domain where the ContentAPI instance lives.";
  };

  options.sbs2.apiSecure = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Where the location where the ContentAPI instance lives is secure.";
  };

  config = {
    systemd.tmpfiles.settings.sbs2Rules = {
      "${cfg.outputDir}"."d" = {
        mode = "755";
	user = "www-data";
	group = "www-data";
      };
    };
    systemd.services.build-and-copy = {
      description = "Copy builkd results to output directory";
      script = ''
        repoDir=$(mktemp -d)

        # Clone the repository to the temporary directory
	cp -rT ${repo} $repoDir

	sed -i 's/git/${gitPath}/g' $repoDir/admin/build.sh

        # Run the build script
        cd $repoDir
	./admin/build.sh

        # Copy the results to the output directory
        cp -r $repoDir/_build.html ${cfg.outputDir}
        cp -r $repoDir/resource ${cfg.outputDir}
      '';
      wantedBy = [ "multi-user.target" ];
      confinement.packages = [ pkgs.git ];
    };
  };
}
