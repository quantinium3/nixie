{
  virtualisation = {
    docker = {
      enable = true;
      enableOnBoot = true;
    };
    oci-containers = {
      /* backend = "podman";
      containers = {
        "navidrome" = {
          image = "deluan/navidrome:latest";
          user = "1000:100";
          ports = [
            "4533:4533"
          ];
          autoStart = true;
          environment = {
            ND_LOGLEVEL = "debug";
          };
          volumes = [
            "/var/lib/navidrome/data:/data"
            "/home/nixie/music:/music:ro"
          ];
        };
        }; */
    };
  };
}
