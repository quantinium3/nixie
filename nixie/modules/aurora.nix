{
  systemd.services.aurora = {
    description = "aurora backend";
    after = [ "network.target" "postgresql.service" "local-fs.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      User = "nixie";
      Restart = "always";
      ExecStart = "/home/nixie/aurora/aurora";
    };
  };
}
