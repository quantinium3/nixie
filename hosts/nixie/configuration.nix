{ modulesPath, stateVersion, input, ... } @ args: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
    ../../nixie/modules
  ];

  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";

    age = {
        sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
        keyFile = "/var/lib/sops-nix/keys.txt";
        generateKey = true;
    };
  };

  sops.secrets = {
    "services/lated/port" = {
      owner = "nixie";
    };
    "services/lated/username" = {
      owner = "nixie";
    };
    "services/lated/password" = {
      owner = "nixie";
    };
  };

  services.openssh.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = stateVersion;
}

