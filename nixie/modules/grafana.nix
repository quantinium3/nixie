{config, pkgs, ...}: {
    services.grafana = {
        enable = true;
        domain = "grafana.quantinium.dev";
        port = "2342";
        addr = "127.0.0.1";
    };
}
