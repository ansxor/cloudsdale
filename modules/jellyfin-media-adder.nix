{ config, pkgs, lib, ... }:

let
  inherit (lib) mkIf getExe maintainers mkEnableOption mkOption mkPackageOption;
  inherit (lib.types) str path int;
  cfg = config.services.jellyfin-media-adder;
in
{
  options.services.jellyfin-media-adder = {
    enable = mkEnableOption "Jellyfin Media Adder";

    package = mkPackageOption pkgs "jellyfin-media-adder" { };

    user = mkOption {
      type = str;
      default = "jellyfin-media-adder";
      description = "User account under which the Jellyfin media adder runs";
    };

    group = mkOption {
      type = str;
      default = "jellyfin-media-adder";
      description = "Group under which the Jellyfin media adder runs";
    };

    outputDir = mkOption {
      type = path;
      default = "./output";
      description = "Location where the songs will be stored.";
    };

    port = mkOption {
      type = int;
      default = 8000;
      description = "Exposed port for Jellyfin Media Adder";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.jellyfin-media-adder = {
      enable = true;
      description = "ContentAPI";

      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        AmbientCapabilities = "CAPI_NET_BIND_SERVICE";
	User = cfg.user;
	Group = cfg.group;
	ExecStart = "${getExe cfg.package}";
      };

      environment = {
        OUTPUT_DIR = cfg.outputDir;
      };
    };

    users.users = mkIf (cfg.user == "jellyfin-media-adder") {
      contentapi = {
        inherit (cfg) group;
	isSystemUser = true;
      };
    };

    users.groups = mkIf (cfg.group == "jellyfin-media-adder") {
      contentapi = {};
    };
  };
}
