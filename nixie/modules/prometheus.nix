{
  services.prometheus = {
    enable = true;
    port = 8001;

    exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "systemd" ];
        port = 8002;
      };
    };

    scrapeConfigs = [
      {
        job_name = "aeris";
        static_configs = [{
          targets = [ "127.0.0.1:8002" ];
        }];
      }
    ];
  };
}
