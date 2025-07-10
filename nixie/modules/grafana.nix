{config, pkgs, ...}: {
    services.grafana = {
        enable = true;
        settings = {
            server = {
                http_addr = "127.0.0.1";
                http_port = 8000;
                domain = "grafana.quantinium.dev";
                serve_from_sub_path = true;
            };
        };
    };
}
