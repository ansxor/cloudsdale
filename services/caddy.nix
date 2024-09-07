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

    virtualHosts."jellyfin-media-adder.shy.home.arpa".extraConfig = ''
      tls internal
      rewrite /ca.crt /var/lib/caddy/.local/share/caddy/certificates/local/jellyfin-media-adder.shy.home.arpa/jellyfin-media-adder.shy.home.arpa.crt
      handle /ca.crt {
	root * /var/lib/caddy/.local/share/caddy/certificates/local/jellyfin-media-adder.shy.home.arpa
	file_server
      }
      reverse_proxy http://localhost:8000
    '';
    
    virtualHosts."http://cert.shy.home.arpa".extraConfig = ''
      handle /root.crt {
        root * /var/lib/caddy/.local/share/caddy/pki/authorities/local
	file_server
      }
    '';
  };
}