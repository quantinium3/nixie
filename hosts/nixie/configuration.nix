{ modulesPath, stateVersion, ... } @ args: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
    ../../nixie/modules
  ];
  sops.defaultSopsFile = ../../secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/home/nixie/.config/sops/age/keys.txt";

  sops.secrets = {
    "myservices/lated/port" = {
      owner = "nixie";
    };
    "myservices/lated/username" = {
      owner = "nixie";
    };
    "myservices/lated/password" = {
      owner = "nixie";
    };
  };
  services.openssh.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = stateVersion;
}

