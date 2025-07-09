{
  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/home/quantinium/.config/sops/age/keys.txt";

    secrets = {
      "myservices/lated/port" = { owner = "nixie"; };
      "myservices/lated/username" = { owner = "nixie"; };
      "myservices/lated/password" = { owner = "nixie"; };
    };
  };
}
