{ config, lib, pkgs, ... }:

let
  cfg = config.restack.ha;
in
{
  options.restack.ha = {
    enable = lib.mkEnableOption "Restack HA module (MongoDB replica set)";

    role = lib.mkOption {
      type = lib.types.enum [ "primary" "replica" ];
      description = "Role of this node in the replica set.";
    };

    replicaSetName = lib.mkOption {
      type = lib.types.str;
      default = "restack-rs";
      description = "MongoDB replica set name.";
    };
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.config.allowUnfree = true;
    # CVE-2025-14847 affects all MongoDB versions in nixpkgs 25.05 — permitted for dev VMs;
    # upgrade path: pin to a patched build once available upstream
    nixpkgs.config.permittedInsecurePackages = [ "mongodb-6.0.23" ];

    services.mongodb = {
      enable = true;
      package = pkgs.mongodb-6_0;
      extraConfig = ''
        replication:
          replSetName: "${cfg.replicaSetName}"
      '';
    };

    networking.firewall.allowedTCPPorts = [
      27017  # MongoDB / replica set communication
    ];
  };
}
