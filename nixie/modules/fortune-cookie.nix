{ pkgs, inputs, ... }:
{
  /* nix.settings.substituters = [ "https://quantinium3.cachix.org" ];
  nix.settings.trusted-public-keys = [ (builtins.readFile ../../secrets/keys/cachix_pub_key)  ]; */

  environment.systemPackages = [ inputs.fortune-cookie.packages.${pkgs.system}.default ];

  systemd.services.fortune-cookie = {
    description = "Fortune Cookie Backend";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${inputs.fortune-cookie.packages.${pkgs.system}.default}/bin/fortune-cookie";
      Restart = "always";
      StandardOutput = "journal";
      StandardError = "journal";
    };
  };
}
