{
  systemd.services.aurora = {
    description = "coderunner";
    after = [ "network.target" "local-fs.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      User = "nixie";
      Restart = "always";
      ExecStart = "/home/nixie/coderunner/target/release/comphub";
    };
  };
}
