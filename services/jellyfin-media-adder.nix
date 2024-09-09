{ config, localPkgs, ... }:
{
  services.jellyfin-media-adder = {
    enable = true;
    package = localPkgs.jellyfin-media-adder;
    user = "jellyfin";
    group = "jellyfin";
    outputDir = "/home/jellyfin/Music";

    jellyfinUsername = "jellyfin-media-adder";
    jellyfinPassword = "AxYainFfPPMZBZsYz7icg76lXBCdz8V9";
    jellyfinLibraryId = "7e64e319657a9516ec78490da03edccb";
  };
}
