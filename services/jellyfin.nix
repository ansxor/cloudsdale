{ config, ... }:
{
  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  users.users.jellyfin = {
    description = "Jellyfin";
    isSystemUser = true;
    home = "/home/jellyfin";
  };
}
