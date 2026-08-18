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

    services.mongodb = {
      enable = true;
      package = pkgs.callPackage ../../packages/mongodb-prebuilt.nix {};
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
