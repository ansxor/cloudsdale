{ config, pkgs, lib, ... }:

let
  repoUrl = "https://github.com/12Me21/sbs2.git";
  repo = pkgs.fetchFromGitHub {
    owner = "12Me21";
    repo = "sbs2";
    rev = "ff6bfbfef0ee8fc6c7608ea3b4b20c4a54529642";
    sha256 = "sha256-e/eWb2tfFBskRtora6R9l8/opD/PqnRXqEKWe/GFugE=";
    fetchSubmodules = true;
    deepClone = true;
    leaveDotGit = true;
  };
  gitPath = lib.replaceStrings ["/"] ["\\/"] "${pkgs.git}/bin/git";
  cfg = config.sbs2;
in
{
  options.sbs2.outputDir = lib.mkOption {
    type = lib.types.str;
    default = "/var/www/sbs2";
    description = "Directory where SBS2 build files will be put.";
  };

  config = {
    systemd.tmpfiles.settings.sbs2Rules = {
      "${cfg.outputDir}"."d" = {
        mode = "755";
	user = "root";
	group = "root";
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
        cp -r $repoDir/resources ${cfg.outputDir}
      '';
      wantedBy = [ "multi-user.target" ];
      confinement.packages = [ pkgs.git ];
    };
  };
}
