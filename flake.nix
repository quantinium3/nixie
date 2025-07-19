{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    deploy-rs.url = "github:serokell/deploy-rs";
  };
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
      hosts = [
        { username = "nixie"; hostname = "nixie.quantinium.dev"; stateVersion = "25.05"; config = ./hosts/nixie/configuration.nix; }
      ];
      pkgs = import nixpkgs { inherit system; };
      deployPkgs = import nixpkgs {
        inherit system;
        overlays = [
          deploy-rs.overlays.default
          (self: super: { deploy-rs = { inherit (pkgs) deploy-rs; lib = super.deploy-rs.lib; }; })
        ];
      };
      makeSystem = { username, hostname, stateVersion, config }: nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs username hostname stateVersion;
        };
        modules = [
          ./hosts/${username}/digitalocean.nix
          disko.nixosModules.disko
          { disko.devices.disk.disk1.device = "/dev/vda"; }
          config
          sops-nix.nixosModules.sops
        ];
      };
    in
    {
      nixosConfigurations = builtins.listToAttrs (map
        (host: {
          name = host.username;
          value = makeSystem {
            inherit (host) username hostname stateVersion config;
          };
        })
        hosts);

      deploy.nodes = builtins.listToAttrs (map
        (host: {
          name = host.username;
          value = {
            hostname = host.username;
            fastConnection = true;
            profiles = {
              nixie = {
                sshUser = "root";
                path = deployPkgs.deploy-rs.lib.activate.nixos self.nixosConfigurations."${host.username}";
                user = "root";
              };
            };
          };
        })
        hosts);

      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
