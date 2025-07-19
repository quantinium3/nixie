{ pkgs, inputs, ... }:
{
  nix.settings.substituters = [ "https://quantinium3.cachix.org" ];
  nix.settings.trusted-public-keys = [ (builtins.readFile ../../secrets/keys/cachix_pub_key)  ];

  environment.systemPackages = [ inputs.fortune-cookie.packages.${pkgs.system}.default ];

  systemd.services.backend = {
    description = "Rust Backend Service";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${inputs.fortune-cookie.packages.${pkgs.system}.default}/bin/fortune-cookie";
      Restart = "always";
      TimeoutStartSec = 30;
      StandardOutput = "journal";
      StandardError = "journal";
    };
  };
}
