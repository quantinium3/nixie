{
  imports = [
    ./grub.nix
    ./networking.nix
    ./postgres.nix
    ./acme.nix
    ./nginx.nix
    ./virtualization.nix
    ./packages.nix
    ./user.nix
    ./aurora.nix
    ./minido.nix
/*     ./lated.nix */
    ./grafana.nix
  ];
}
