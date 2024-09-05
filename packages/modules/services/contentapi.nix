{ config, pkgs, lib, ... }:

let
  inherit (lib) mkIf getExe maintainers mkEnableOption mkOption mkPackageOption;
  inherit (lib.types) str path bool int;
  cfg = config.services.contentapi;
in
{
  options = {
    services.contentapi = {
      enable = mkEnableOption "ContentAPI";

      package = mkPackageOption pkgs "contentapi" { };

      user = mkOption {
        type = str;
	default = "contentapi";
	description = "User account under which ContentAPI runs.";
      };

      group = mkOption {
        type = str;
	default = "contentapi";
	description = "Group under which ContentAPI runs.";
      };

      workingDir = mkOption {
        type = path;
	default = "/var/lib/contentapi";
	description = "Working directory for ContentAPI database and appsettings.json.";
      };

      port = mkOption {
        type = int;
	default = 5000;
	description = "Exposed port for ContentAPI.";
      };
    };
  };

  config = mkIf cfg.enable {
    systemd = {
      services.contentapi = {
        enable = true;
        description = "ContentAPI";

	after = [ "network-online.target" ];
	wants = [ "network-online.target" ];
	wantedBy = [ "multi-user.target" ];

	serviceConfig = {
	  AmbientCapabilities = "CAP_NET_BIND_SERVICE";
          User = cfg.user;
	  Group = cfg.group;
	  WorkingDirectory = cfg.workingDir;
	  ExecStart = "${getExe cfg.package} --urls 'http://localhost:${cfg.port}'";
	};
      };
    };

    users.users = mkIf (cfg.user == "contentapi") {
      contentapi = {
        inherit (cfg) group;
	isSystemUser = true;
      };
    };

    users.groups = mkIf (cfg.group == "contentapi") {
      contentapi = {};
    };
  };
}
