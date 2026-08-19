{ config, lib, pkgs, ... }:

let
  cfg = config.restack.ferretdb;
in
{
  options.restack.ferretdb = {
    enable = lib.mkEnableOption "FerretDB — MongoDB-compatible layer over PostgreSQL (Apache-2.0)";

    port = lib.mkOption {
      type = lib.types.port;
      default = 27017;
      description = "Port FerretDB listens on (MongoDB wire protocol).";
    };

    postgresDatabase = lib.mkOption {
      type = lib.types.str;
      default = "ferretdb";
      description = "PostgreSQL database FerretDB uses as its storage backend.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Create the ferretdb PostgreSQL user and database before FerretDB starts
    services.postgresql.ensureDatabases = [ cfg.postgresDatabase ];
    services.postgresql.ensureUsers = [{
      name = "ferretdb";
      ensureDBOwnership = true;
    }];

    systemd.services.ferretdb = {
      description = "FerretDB — MongoDB wire protocol over PostgreSQL";
      wantedBy = [ "multi-user.target" ];
      after = [ "postgresql.service" ];
      requires = [ "postgresql.service" ];
      environment = {
        FERRETDB_LISTEN_ADDR = ":${toString cfg.port}";
        FERRETDB_POSTGRESQL_URL = "postgres://ferretdb@localhost/${cfg.postgresDatabase}?sslmode=disable";
        FERRETDB_LOG_LEVEL = "info";
      };
      serviceConfig = {
        ExecStart = "${pkgs.ferretdb}/bin/ferretdb";
        Restart = "on-failure";
        RestartSec = "5s";
        DynamicUser = true;
      };
    };

    networking.firewall.allowedTCPPorts = [ cfg.port ];
  };
}
