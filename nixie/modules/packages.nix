{ pkgs, lib, ... }: {
  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
    pkgs.neovim
    pkgs.bun
    pkgs.openssl
    pkgs.fish
  ];
}
