{ modulesPath
, lib
, pkgs
, ...
} @ args:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
    ../../nixie/modules
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

  security.acme.defaults.email = "quant@quantinium.dev";
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

  systemd.services.minido = {
    description = "Minido";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.bun}/bin/bun /home/nixie/minido/dist/index.js";
      WorkingDirectory = "/home/nixie/minido/app/backend";
      Restart = "always";
      User = "nixie";
      Environment = [
        "DATABASE_URL=postgres://postgres:030504@localhost:5432/mindo"
      ];
    };
  };

  systemd.services.lated = {
    description = "Lated";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.bun}/bin/bun /home/nixie/lated/backend/server.js";
      WorkingDirectory = "/home/nixie/lated/backend";
      Restart = "always";
      User = "nixie";
      Environment = [
        "PORT="
        "USERNAME="
        "PASSWORD="
      ];
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

    commonHttpConfig =
      let
        realIpsFromList = lib.strings.concatMapStringsSep "\n" (x: "set_real_ip_from  ${x};");
        fileToList = x: lib.strings.splitString "\n" (builtins.readFile x);
        cfipv4 = fileToList (pkgs.fetchurl {
          url = "https://www.cloudflare.com/ips-v4";
          sha256 = "0ywy9sg7spafi3gm9q5wb59lbiq0swvf0q3iazl0maq1pj1nsb7h";
        });
        cfipv6 = fileToList (pkgs.fetchurl {
          url = "https://www.cloudflare.com/ips-v6";
          sha256 = "1ad09hijignj6zlqvdjxv7rjj8567z357zfavv201b9vx3ikk7cy";
        });
      in
      ''
        ${realIpsFromList cfipv4}
        ${realIpsFromList cfipv6}
        real_ip_header CF-Connecting-IP;
      '';

    virtualHosts = {
      "natsuki.quantinium.dev" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1";
          return = "200 '<html><body>It works</body></html>'";
          extraConfig = ''
            default_type text/html;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
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

      "minido.quantinium.dev" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:4001/";
          extraConfig = ''
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
          '';
        };
      };

      "lated.quantinium.dev" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:5001/";
          extraConfig = ''
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
          '';
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

  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
    pkgs.neovim
    pkgs.neofetch
    pkgs.bun
    pkgs.texliveFull
  ];


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

  system.stateVersion = "24.05";
}

