{ modulesPath, inputs, ... } @ args: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
    ../../nixie/modules
    inputs.sops-nix.nixosModules.sops
  ];

  _module.args.sops = inputs.sops-nix;
  services.openssh.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "24.05";
}

