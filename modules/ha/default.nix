{ config, lib, pkgs, ... }:

let
  cfg = config.restack.ha;
in
{
  options.restack.ha = {
    enable = lib.mkEnableOption "Restack HA module (PostgreSQL streaming replication)";

    role = lib.mkOption {
      type = lib.types.enum [ "primary" "replica" ];
      description = "Role of this node in the PostgreSQL streaming replication setup.";
    };

    primaryHost = lib.mkOption {
      type = lib.types.str;
      default = "192.168.122.101";
      description = "IP address of the primary node; used by replicas to bootstrap and stream.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.postgresql = {
      enable = true;
      package = pkgs.postgresql_16;
      enableTCPIP = true;

      settings = lib.mkMerge [
        { hot_standby = true; }
        (lib.mkIf (cfg.role == "primary") {
          wal_level = "replica";
          max_wal_senders = 3;
          wal_keep_size = "64MB";
        })
      ];

      # Allow replication connections from the VM subnet; all other auth is trust for local
      authentication = lib.mkOverride 10 ''
        local  all          all                         trust
        host   all          all          127.0.0.1/32   trust
        host   all          all          ::1/128         trust
        host   replication  replicator   192.168.122.0/24  trust
      '';

      initialScript = lib.mkIf (cfg.role == "primary") (pkgs.writeText "pg-primary-init" ''
        CREATE ROLE replicator WITH REPLICATION LOGIN;
      '');
    };

    # Replica: bootstrap data dir from primary via pg_basebackup before PostgreSQL starts.
    # The -R flag writes standby.signal and primary_conninfo into the data dir so the
    # replica connects and streams automatically on every subsequent boot.
    systemd.services.postgresql-replica-init = lib.mkIf (cfg.role == "replica") {
      description = "Bootstrap PostgreSQL replica from primary via pg_basebackup";
      after = [ "systemd-tmpfiles-setup.service" "network-online.target" ];
      wants = [ "network-online.target" ];
      before = [ "postgresql.service" ];
      requiredBy = [ "postgresql.service" ];
      serviceConfig = {
        Type = "oneshot";
        User = "postgres";
        RemainAfterExit = true;
        StateDirectory = "postgresql";
        StateDirectoryMode = "0700";
      };
      script =
        let
          pgData = config.services.postgresql.dataDir;
          pgBasebackup = "${config.services.postgresql.package}/bin/pg_basebackup";
        in
        ''
          if [ ! -f "${pgData}/standby.signal" ]; then
            rm -rf "${pgData}"
            ${pgBasebackup} \
              -h ${cfg.primaryHost} \
              -U replicator \
              -D "${pgData}" \
              -P -Xs -R
            chmod 700 "${pgData}"
          fi
        '';
    };

    networking.firewall.allowedTCPPorts = [ 5432 ];
  };
}
