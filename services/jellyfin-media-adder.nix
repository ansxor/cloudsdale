{ config, localPkgs, ... }:
{
  services.jellyfin-media-adder = {
    enable = true;
    package = localPkgs.jellyfin-media-adder;
    user = "jellyfin";
    group = "jellyfin";
    outputDir = "/home/jellyfin/Music";
  };
}
