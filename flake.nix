{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  inputs.disko.url = "github:nix-community/disko";
  inputs.disko.inputs.nixpkgs.follows = "nixpkgs";

  inputs.sops-nix.url = "github:Mic92/sops-nix";
  inputs.sops-nix.inputs.nixpkgs.follows = "nixpkgs";

  inputs.deploy-rs.url = "github:serokell/deploy-rs";

  outputs =
    { self
    , nixpkgs
    , disko
    , sops-nix
    , deploy-rs
    , ...
    }@inputs:
    let
      system = "x86_64-linux";
      user = "nixie";
      hosts = [
        { hostname = "nixie"; stateVersion = "25.05"; }
      ];
      pkgs = import nixpkgs { inherit system; };
      deployPkgs = import nixpkgs {
        inherit system;
        overlays = [
          deploy-rs.overlays.default
          (self: super: { deploy-rs = { inherit (pkgs) deploy-rs; lib = super.deploy-rs.lib; }; })
        ];
      };
      makeSystem = { hostname, stateVersion }: nixpkgs.lib.nixosSystem
        {
          system = system;
          specialArgs = {
            inherit inputs stateVersion hostname user;
          };
          modules = [
            ./hosts/${hostname}/digitalocean.nix
            disko.nixosModules.disko
            { disko.devices.disk.disk1.device = "/dev/vda"; }
            ./hosts/${hostname}/configuration.nix
            sops-nix.nixosModules.sops
          ];
        };
    in
    {
      nixosConfigurations = nixpkgs.lib.foldl'
        (configs: host:
          configs // {
            "${host.hostname}" = makeSystem {
              inherit (host) hostname stateVersion;
            };
          })
        { }
        hosts;

      deploy.nodes.nixie = {
        hostname = "nixie";
        fastConnection = true;
        interactiveSudo = true;
        profile = {
          nixie = {
            sshUser = "nixie";
            path = deployPkgs.deploy-rs.lib.activate.nixos self.nixosConfigurations.nixie;
            user = "nixie";
          };
        };
      };

      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;

    };

}
