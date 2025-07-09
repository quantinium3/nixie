{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  inputs.disko.url = "github:nix-community/disko";
  inputs.disko.inputs.nixpkgs.follows = "nixpkgs";

  inputs.sops-nix.url = "github:Mic92/sops-nix";
  inputs.sops-nix.inputs.nixpkgs.follows = "nixpkgs";

  outputs =
    { nixpkgs
    , disko
    , sops-nix
    , ...
    }@inputs:
    let
      system = "x86_64-linux";
      user = "nixie";
      hosts = [
        { hostname = "nixie"; stateVersion = "25.05"; }
      ];
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
    };
}
