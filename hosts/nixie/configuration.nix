{ modulesPath
, lib
, pkgs
, ...
} @ args:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
    ../../nixie/modules
  ];

  services.openssh.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

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
        "PORT="
        "USERNAME="
        "PASSWORD="
      ];
    };
  };

  system.stateVersion = "24.05";
}

