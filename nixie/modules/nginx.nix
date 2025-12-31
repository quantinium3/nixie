{
	services.nginx = {
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

		virtualHosts."xunback.quantinium.dev" = {
			addSSL = true;
			sslCertificate = "/var/lib/cloudflare/xunback.quantinium.dev.pem";
			sslCertificateKey = "/var/lib/cloudflare/xunback.quantinium.dev.key";
			locations."/" = {
				proxyPass = "http://127.0.0.1:3001";
				proxyWebsockets = false;
		  };
		}
  };

  systemd.tmpfiles.rules = [
    "d /var/log/nginx 0750 nginx nginx -"
  ];
}


