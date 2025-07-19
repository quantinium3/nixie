{
  imports = [
    ./grub.nix
    ./networking.nix
    ./postgres.nix
    ./nginx.nix
    ./virtualization.nix
    ./packages.nix
    ./user.nix
    ./aurora.nix
    ./minido.nix
/*     ./lated.nix */
    ./grafana.nix
    ./prometheus.nix
    ./loki.nix
    ./alloy.nix
    ./fortune-cookie.nix
  ];
}
