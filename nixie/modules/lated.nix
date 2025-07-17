{ pkgs, config, ... }: {
  sops.secrets = {
    "services/lated/port" = {
      owner = "nixie";
    };
    "services/lated/username" = {
      owner = "nixie";
    };
    "services/lated/password" = {
      owner = "nixie";
    };
  };

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
        "PORT=${config.sops.secrets."services/lated/port".path}"
        "USERNAME=${config.sops.secrets."services/lated/username".path}"
        "PASSWORD=${config.sops.secrets."services/lated/password".path}"
      ];
    };
  };
}
