{ config, localPkgs, ... }:
{
  services.contentapi = {
    enable = true;
    package = localPkgs.contentapi;
  };
}
