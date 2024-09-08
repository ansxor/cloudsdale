{ config, ... }:
{
  services.caddy = {
    enable = true;

    globalConfig = ''
      auto_https disable_redirects
    '';

    virtualHosts."http://git.shy.home.arpa".extraConfig = ''
      reverse_proxy http://localhost:3000
    '';

    virtualHosts."http://media.shy.home.arpa".extraConfig = ''
      reverse_proxy http://localhost:8096
    '';

    virtualHosts."http://content.shy.home.arpa".extraConfig = ''
      reverse_proxy /api http://127.0.0.1:5000

      root * /var/www/sbs2
      file_server
    '';

    virtualHosts."http://jellyfin-media-adder.shy.home.arpa".extraConfig = ''
      reverse_proxy http://localhost:8000
    '';
  };
}
