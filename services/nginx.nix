{ config, ... }:
{
  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;

    virtualHosts."git.shy.home.arpa" = {
      locations."/".proxyPass = "http://localhost:3000";
    };

    virtualHosts."media.shy.home.arpa" = {
      locations."/".proxyPass = "http://localhost:8096";
    };

    virtualHosts."content.shy.home.arpa" = {
      locations."/".proxyPass = "http://127.0.0.1:5000";
    };
  };
}
