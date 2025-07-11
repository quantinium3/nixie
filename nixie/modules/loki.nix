{
  services.loki = {
    enable = true;
    configuration = {
      server.http_listen_port = 8500;
      auth_enabled = false;

      common = {
        path_prefix = "/var/lib/loki";
        storage = {
          filesystem = {
            chunks_directory = "/var/lib/loki/chunks";
            rules_directory = "/var/lib/loki/rules";
          };
        };
      };

      ingester = {
        lifecycler = {
          address = "127.0.0.1";
          ring = {
            kvstore.store = "inmemory";
            replication_factor = 1;
          };
          final_sleep = "0s";
        };
        chunk_idle_period = "1h";
        max_chunk_age = "1h";
        chunk_target_size = 1572864;
        chunk_retain_period = "30s";
      };

      schema_config.configs = [
        {
          from = "2020-05-15";
          store = "tsdb";
          object_store = "filesystem";
          schema = "v13";
          index = {
            prefix = "index_";
            period = "24h";
          };
        }
      ];

      storage_config = {
        filesystem.directory = "/var/lib/loki/chunks";
        tsdb_shipper = {
          active_index_directory = "/var/lib/loki/index";
          cache_location = "/var/lib/loki/cache";
        };
      };

      compactor = {
        working_directory = "/var/lib/loki/compactor";
      };

      limits_config = {
        reject_old_samples = true;
        reject_old_samples_max_age = "1w";
      };

      table_manager = {
        retention_deletes_enabled = false;
        retention_period = "0s";
      };
    };
  };


}
