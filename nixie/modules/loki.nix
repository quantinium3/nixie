{
  services.loki = {
    enable = true;
    configuration = {
      server = {
        http_listen_port = 8500;
        grpc_listen_port = 9096;
        log_level = "debug";
        grpc_server_max_concurrent_streams = 1000;
      };
      auth_enabled = false;

      common = {
        instance_addr = "127.0.0.1";
        path_prefix = "/tmp/loki";
        storage = {
          filesystems = {
            chunks_directory = "/tmp/loki/chunks";
            rules_directory = "/tmp/loki/rules";
          };
        };
        replication_factor = 1;
        ring = {
          kvstore = {
            store = "inmemory";
          };
        };
      };

      query_range = {
        results_cache = {
          cache = {
            embedded_cache = {
              enabled = true;
              max_size_mb = 100;
            };
          };
        };
      };

      limits_config = {
          metric_aggregation_enabled = true;
          enable_multi_variant_queries = true;
          reject_old_samples = true;
          reject_old_samples_max_age = "168h";
      };

      schema_config = {
        config = [
          { 
              from = "2025-07-11";
              store = "tsdb";
              object_store = "filesystem";
              schema = "v13";
              index = {
                  prefix = "index_";
                  period = "24h";
              };
          }
        ];
      };
    
      table_manager = {
          retention_deleted_enabled = false;
          retention_period = "0s";
      };

      storage_config = {
          filesystem = {
              directory = "/tmp/loki/chunks";
          };
      };
    };
  };
}
