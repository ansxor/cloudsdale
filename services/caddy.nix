{ config, ... }:
{
  services.caddy = {
    enable = true;

    virtualHosts."git.shy.home.arpa".extraConfig = ''
      reverse_proxy http://localhost:3000
    '';
  };
}
