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
  system.activationScripts.buildScript = ''
    if [ -d "${repoDir}" ]; then
      cd "${repoDir}"
      ${pkgs.writeShellScript "build.sh" ''
        #!/bin/sh
	./admin/build.sh
      ''}
    fi
  '';

  system.activationScripts.copyResults = ''
    if [ -d "${repoDir}" ]; then
      cp -r "${repoDir}/_build.html "${outputDir}/index.html"
      cp -r "${repoDir}/resources" "${outputDir}"
    fi
  '';
}
