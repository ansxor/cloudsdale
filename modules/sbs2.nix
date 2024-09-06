{ config, pkgs, ... }:

{ outputDir ? "/var/www/sbs2" }:

let
  repoDir = pkgs.runCommand "repo-dir" {} ''
    dir=$(${pkgs.stdenv.shell} -c "mktemp -d")
    echo "$dir" > $out
  '';
  repo = pkgs.fetchFromGitHub {
    owner = "12Me21";
    repo = "sbs2";
    rev = "ff6bfbfef0ee8fc6c7608ea3b4b20c4a54529642";
    fetchSubmodules = true;
  };
in
{
  config = {
    systemd.services.build-script = {
      description = "Build script for SBS2";
      script = ''
        cd  "${repoDir}"
        ./admin/build.sh
      '';
      wantedBy = [ "multi-user.target" ];
    };

    systemd.services.copy-results = {
      description = "Copy builkd results to output directory";
      script = ''
        cp -r "${repoDir}/_build.html "${outputDir}/index.html"
        cp -r "${repoDir}/resources" "${outputDir}"
      '';
      wantedBy = [ "multi-user.target" ];
    };
  };
}
