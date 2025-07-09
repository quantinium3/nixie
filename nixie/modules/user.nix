{ pkgs, ... }@ args: {
  users.users."nixie" = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
    createHome = true;
  };
  users.users."nixie".openssh.authorizedKeys.keys = [
    ""
  ] ++ (args.extraPublicKeys or [ ]);

  users.users.root.openssh.authorizedKeys.keys =
    [
      ""
    ] ++ (args.extraPublicKeys or [ ]);

}
