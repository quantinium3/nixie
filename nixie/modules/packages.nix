{ pkgs, lib, ... }: {
  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
    pkgs.neovim
    pkgs.neofetch
    pkgs.bun
    pkgs.texliveFull

    pkgs.openssl
  ];
}
