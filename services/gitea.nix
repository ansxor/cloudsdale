{ config, pkgs, ... }:
{
  # Gitea
  virtualisation.oci-containers.containers."gitea" = {
    autoStart = true;
    image = "gitea/gitea:latest";
    environment = {
      USER_UID = "1000";
      USER_GID = "1000";
    };
    volumes = [
      "/home/answer/gitea:/data"
    ];
    ports = [
      "3000:3000"
      "222:22"
    ];
  };

}
