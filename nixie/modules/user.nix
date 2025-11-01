{ username, config, ... }: {

  users = {
    users = {
			# ${username} = {
      #   isNormalUser = true;
      #   extraGroups = [ "wheel" "docker" ];
      #   hashedPasswordFile = config.sops.secrets."nixie/password".path;
      #   createHome = true;
      #   openssh.authorizedKeys.keys = [
      #     (builtins.readFile ../../secrets/keys/id_nixie.pub)
      #   ];
      # };
      root = {
        openssh.authorizedKeys.keys = [
					"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINCRfaGQt/jK6vJo19EYIOAZPzm4jUd3QVHCWETMXSsJ quantinium@fedora"
        ];
      };
    };
  };
}
