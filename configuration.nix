{ modulesPath
, lib
, pkgs
, ...
} @ args:
let
  secrets = import ./secrets.nix;
in
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
  ];
  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  services.openssh.enable = true;

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443 22 ];
  };
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_15;
    authentication = pkgs.lib.mkOverride 10 ''
      local all all trust
      host all all 127.0.0.1/32 trust
      host all all ::1/128 trust
    '';
  };

  security.acme.defaults.email = secrets.acmeEmail;
  security.acme.acceptTerms = true;

  systemd.services.aurora = {
    description = "aurora backend";
    after = [ "network.target" "postgresql.service" "local-fs.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      User = "nixie";
      Restart = "always";
      ExecStart = "/home/nixie/aurora/aurora";
    };
  };

  services.nginx = {
    enable = true;

    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    sslCiphers = "AES256+EECDH:AES256+EDH:!aNULL";

    appendHttpConfig = ''
      map $scheme $hsts_header {
            https   "max-age=31536000; includeSubdomains; preload";
      }

      add_header Strict-Transport-Security $hsts_header;

      # Enable CSP for your services.
      #add_header Content-Security-Policy "script-src 'self'; object-src 'none'; base-uri 'none';" always;

      # Minimize information leaked to other domains
      add_header 'Referrer-Policy' 'origin-when-cross-origin';

      # Disable embedding as a frame
      add_header X-Frame-Options DENY;

      # Prevent injection of code in other mime types (XSS Attacks)
      add_header X-Content-Type-Options nosniff;

      # This might create errors
      proxy_cookie_path / "/; secure; HttpOnly; SameSite=strict";
    '';

    virtualHosts = {
      localhost = {
        locations."/" = {
          return = "200 '<html><body>It works</body></html>'";
          extraConfig = ''
            default_type text/html;
          '';
        };
      };

      "lucy.quantinium.dev" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:4000/";
        };
      };
    };
  };

  virtualisation = {
    docker = {
      enable = true;
      enableOnBoot = true;
    };
    oci-containers = {
      backend = "docker";
      containers = { };
    };
  };

  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
    pkgs.neovim
    pkgs.neofetch
  ];


  users.users."nixie" = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
    createHome = true;
  };
  users.users."nixie".openssh.authorizedKeys.keys = secrets.sshKeys.quantinium ++ (args.extraPublicKeys or [ ]);

  users.users.root.openssh.authorizedKeys.keys = secrets.sshKeys.quantinium ++ (args.extraPublicKeys or [ ]);

  system.stateVersion = "24.05";
}
