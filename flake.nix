{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    colmena.url = "github:zhaofengli/colmena";
  };

  outputs =
    { self
    , nixpkgs
    , disko
    , sops-nix
    , colmena
    , ...
    }@inputs:
    let
      system = "x86_64-linux";
      hosts = [
        { username = "nixie"; hostname = "nixie.quantinium.dev"; stateVersion = "25.05"; config = "./hosts/nixie/configuration.nix"; }
      ];
      makeSystem = { username, hostname, stateVersion, config }: nixpkgs.lib.nixosSystem
        {
          system = system;
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

      colmenaHive = colmena.lib.makeHive self.outputs.colmena;
      colmena = {
        meta = {
          nixpkgs = import nixpkgs { system = system; };
        };
        defaults = { pkgs, ... }: {
          environment.systemPackages = with pkgs; [
            vim
            wget
            curl
          ];
        };
      } // nixpkgs.lib.foldl'
        (configs: host:
          configs // {
            "${host.hostname}" = makeSystem {
              inherit (host) username hostname stateVersion config;
            };

            deployment = {
              targetHost = host.hostname;
              targetUser = host.username;
            };
          })
        { }
        hosts;
    };

}
