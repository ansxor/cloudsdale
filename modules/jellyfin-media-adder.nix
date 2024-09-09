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

    jellyfinServer = mkOption {
      type = str;
      default = "localhost:8096";
      description = "Jellyfin server location.";
    };

    jellyfinUsername = mkOption {
      type = str;
      default = "admin";
      description = "User account that the Jellyfin Media Runner signs in under";
    };

    jellyfinPassword = mkOption {
      type = str;
      default = "admin";
      description = "Password for user account that the Jellyfin Media Runner signs in under";
    };

    jellyfinLibraryId = mkOption {
      type = str;
      default = "PLEASE_INSERT_LIBRARY_ID_HERE";
      description = "Library item ID to be refreshed when new entries are added.";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.jellyfin-media-adder = {
      enable = true;
      description = "Jellyfin Media Adder";

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

	JELLYFIN_SERVER = cfg.jellyfinServer;
	JELLYFIN_USERNAME = cfg.jellyfinUsername;
	JELLYFIN_PASSWORD = cfg.jellyfinPassword;
	JELLYFIN_MUSIC_LIBRARY = cfg.jellyfinLibraryId;
      };
    };

    users.users = mkIf (cfg.user == "jellyfin-media-adder") {
      jellyfin-media-adder = {
        inherit (cfg) group;
	isSystemUser = true;
      };
    };

    users.groups = mkIf (cfg.group == "jellyfin-media-adder") {
      jellyfin-media-adder = {};
    };
  };
}
