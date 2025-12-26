{ pkgs, lib, ... }: {
  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
    pkgs.neovim
		pkgs.fastfetch
		pkgs.lsd
    pkgs.wget
    pkgs.openssl
  ];
}
