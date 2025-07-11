{
  services.loki = {
    enable = true;
    configuration = {
      server = {
        http_listen_port = 8500;
      };
      auth_enabled = false;

      ingestor = {
        lifecycler = {
          address = "127.0.0.1";
          ring = {
            kvstore.store = "inmemory";
            replication_factor = 1;
          };
          final_step = "0s";
        };
        # chunk not receiving logs in 1hr will be flushed
        chunk_idle_period = "1h";
        # all chunk with this age will be flushed
        max_chunk_age = "1h";

        chunk_target_size = "1048576"; # 1.5mb
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
        filesystem.directory = "/tmp/loki/chunks";
      };

      limits_config = {
        reject_old_sample = true;
        reject_old_samples_max_age = "168h";
      };

      table_manager = {
        retention_deletes_enabled = false;
        retention_period = "0s";
      };
    };
  };
}
