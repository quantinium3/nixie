{
  services.alloy = {
    enable = true;
  };
  environment.etc."alloy.config.alloy" = {
    text = ''
      local.file_match "local_files" {
         path_targets = [{"__path__" = "/var/log/*.log"}]
         sync_period = "5s"
      }

      loki.source.file "log_scrape" {
         targets    = local.file_match.local_files.targets
         forward_to = [loki.process.filter_logs.receiver]
         tail_from_end = true
      }
      loki.process "filter_logs" {
        stage.drop {
            source = ""
            expression  = ".*Connection closed by authenticating user root"
            drop_counter_reason = "noisy"
        }
        forward_to = [loki.write.grafana_loki.receiver]
      }
      
      loki.write "grafana_loki" {
        endpoint {
          url = "http://127.0.0.1:8500/loki/api/v1/push"

          // basic_auth {
          //  username = "admin"
          //  password = "admin"
          // }
        }
      }

      prometheus.exporter.unix "integrations_node_exporter" {
        disable_collectors = ["ipvs", "btrfs", "infiniband", "xfs", "zfs"]
        enable_collectors = ["meminfo", "cpu", "diskstats", "filesystem", "loadavg", "netdev"]
      
        filesystem {
          fs_types_exclude     = "^(autofs|binfmt_misc|bpf|cgroup2?|configfs|debugfs|devpts|devtmpfs|tmpfs|fusectl|hugetlbfs|iso9660|mqueue|nsfs|overlay|proc|procfs|pstore|rpc_pipefs|securityfs|selinuxfs|squashfs|sysfs|tracefs)$"
          mount_points_exclude = "^/(dev|proc|run/credentials/.+|sys|var/lib/docker/.+)($|/)"
          mount_timeout        = "5s"
        }
      
        netclass {
          ignored_devices = "^(veth.*|cali.*|[a-f0-9]{15})$"
        }
      
        netdev {
          device_exclude = "^(veth.*|cali.*|[a-f0-9]{15})$"
        }
      }

      discovery.relabel "integrations_node_exporter" {
        targets = prometheus.exporter.unix.integrations_node_exporter.targets
      
        rule {
          target_label = "instance"
          replacement  = constants.hostname
        }
      
        rule {
          target_label = "job"
          replacement = "integrations/node_exporter"
        }
      }

      discovery.relabel "logs_integrations_integrations_node_exporter_journal_scrape" {
        targets = []
      
        rule {
          source_labels = ["__journal__systemd_unit"]
          target_label  = "unit"
        }
      
        rule {
          source_labels = ["__journal__boot_id"]
          target_label  = "boot_id"
        }
      
        rule {
          source_labels = ["__journal__transport"]
          target_label  = "transport"
        }
      
        rule {
          source_labels = ["__journal_priority_keyword"]
          target_label  = "level"
        }
      }

      prometheus.scrape "integrations_node_exporter" {
        scrape_interval = "15s"
        targets    = discovery.relabel.integrations_node_exporter.output
        forward_to = [prometheus.remote_write.local.receiver]
      }

      prometheus.remote_write "local" {
        endpoint {
          url = "http://127.0.0.1:8250/api/v1/write"
        }
      }


      loki.source.journal "logs_integrations_integrations_node_exporter_journal_scrape" {
        max_age       = "24h0m0s"
        relabel_rules = discovery.relabel.logs_integrations_integrations_node_exporter_journal_scrape.rules
        forward_to    = [loki.write.local.receiver]
      }

      local.file_match "logs_integrations_integrations_node_exporter_direct_scrape" {
        path_targets = [{
          __address__ = "localhost",
          __path__    = "/var/log/{syslog,messages,*.log}",
          instance    = constants.hostname,
          job         = "integrations/node_exporter",
        }]
      }

      loki.source.file "logs_integrations_integrations_node_exporter_direct_scrape" {
        targets    = local.file_match.logs_integrations_integrations_node_exporter_direct_scrape.targets
        forward_to = [loki.write.local.receiver]
      }

      loki.write "local" {
        endpoint {
          url = "http://127.0.0.1:8500/loki/api/v1/push"
        }
      }
    '';
  };

}
