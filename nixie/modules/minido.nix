{ pkgs, ... }: {
  systemd.services.minido = {
    description = "Minido";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.bun}/bin/bun /home/nixie/minido/dist/index.js";
      WorkingDirectory = "/home/nixie/minido/app/backend";
      Restart = "always";
      User = "nixie";
      Environment = [
        "DATABASE_URL=postgres://postgres:030504@localhost:5432/mindo"
      ];
    };
  };
}
