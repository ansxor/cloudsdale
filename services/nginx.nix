{ config, ... }:
{
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;

    virtualHosts."git.shy.home.arpa" = {
      locations."/" = {
        proxyPass = "http://localhost:3000";
      };
    };
  };
}
