{
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443 22 ];
		allowedUDPPorts = [ 
			53
			60000
		];
  };
}
