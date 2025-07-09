{ pkgs, sops, ... }: {
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
        ''PORT=${sops.secrets."myservices/lated/port"}''
        ''USERNAME=${sops.secrets."myservices/lated/username"}''
        ''PASSWORD=${sops.secrets."myservices/lated/password"}''
      ];
    };
  };
}
