{ username, config, ... }: {

  sops.secrets = {
    "nixie/password" = {
      owner = "nixie";
      neededForUsers = true;
    };
  };

  users = {
    mutableUsers = true;

    users = {
      ${username} = {
        isNormalUser = true;
        extraGroups = [ "wheel" "docker" ];
        hashedPasswordFile = config.sops.secrets."nixie/password".path;
        createHome = true;
        openssh.authorizedKeys.keys = [
          (builtins.readFile ../../secrets/keys/id_nixie.pub)
        ];
      };
      root = {
        openssh.authorizedKeys.keys = [
          (builtins.readFile ../../secrets/keys/id_nixie.pub)
        ];
      };
    };
  };
}
