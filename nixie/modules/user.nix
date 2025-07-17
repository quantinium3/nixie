{ username, ... }: {
  users = {
    users = {
      ${username} = {
        isNormalUser = true;
        extraGroups = [ "wheel" "docker" ];
        createHome = true;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGnHBe+Aho86G+ZrwMGethZ6o7P4hcKte4a6unrfqi6Y quantinium@nixos"
        ];
      };
      root = {
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGnHBe+Aho86G+ZrwMGethZ6o7P4hcKte4a6unrfqi6Y quantinium@nixos"
        ];
      };
    };
  };
}
