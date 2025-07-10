{ pkgs, config, ... }@ args: {
  users.users."nixie" = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
    createHome = true;
  };
  users.users."nixie".openssh.authorizedKeys.keys = [
    "ssh-ed25519 ${config.sops.secrets.ssh_key.path}"
  ] ++ (args.extraPublicKeys or [ ]);

  users.users.root.openssh.authorizedKeys.keys =
    [
      "ssh-ed25519 ${config.sops.secrets.ssh_key.path}"
    ] ++ (args.extraPublicKeys or [ ]);

}
