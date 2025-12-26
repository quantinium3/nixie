{
	/*services.nginx = {
		enable = true;

    virtualHosts."nixie.quantinium.dev" = {
			addSSL = true;
			sslCertificate = "/var/lib/cloudflare/nixie.quantinium.dev.pem";
			sslCertificateKey = "/var/lib/cloudflare/nixie.quantinium.dev.key";
			locations."/" = {
				proxyPass = "http://127.0.0.1:3000";
				proxyWebsockets = false;
		  };
    }; 
  };*/

services.nginx = {
  enable = true;
 /* virtualHosts.localhost = {
    locations."/" = {
      return = "200 '<html><body>It works</body></html>'";
      extraConfig = ''
        default_type text/html;
      '';
    };
  }; */
};
}


