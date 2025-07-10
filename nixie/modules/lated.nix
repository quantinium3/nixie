{ pkgs, config, ... }: {
  systemd.services.lated = {
    description = "Lated";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.bun}/bin/bun /home/nixie/lated/backend/server.js";
      WorkingDirectory = "/home/nixie/lated/backend";
      Restart = "always";
      User = "nixie";
      Environment = [
        "PORT=${config.sops.secrets."myservices/lated/port".path}"
        "USERNAME=${config.sops.secrets."myservices/lated/username".path}"
        "PASSWORD=${config.sops.secrets."myservices/lated/password".path}"
      ];
    };
  };
}
