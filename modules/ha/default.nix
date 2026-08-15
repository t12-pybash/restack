{ config, lib, pkgs, ... }:

let
  cfg = config.restack.ha;
in
{
  options.restack.ha = {
    enable = lib.mkEnableOption "Restack HA module (Patroni + PostgreSQL)";

    role = lib.mkOption {
      type = lib.types.enum [ "primary" "replica" ];
      description = "Role of this node in the HA cluster.";
    };

    clusterName = lib.mkOption {
      type = lib.types.str;
      default = "restack";
      description = "Patroni cluster name.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.postgresql = {
      enable = true;
      package = pkgs.postgresql_16;
    };

    # Patroni manages PostgreSQL — stub for wiring in patroni config
    # Full patroni NixOS module integration to follow
    environment.systemPackages = with pkgs; [ patroni etcd ];

    networking.firewall.allowedTCPPorts = [
      5432  # PostgreSQL
      8008  # Patroni REST API
      2379  # etcd client
      2380  # etcd peer
    ];
  };
}
