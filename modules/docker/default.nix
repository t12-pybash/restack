{ config, lib, ... }:

let
  cfg = config.restack.docker;
in
{
  options.restack.docker = {
    enable = lib.mkEnableOption "Docker runtime for containerised workloads";
  };

  config = lib.mkIf cfg.enable {
    virtualisation.docker = {
      enable = true;
      autoPrune.enable = true;
    };

    users.users.nixos.extraGroups = [ "docker" ];
  };
}
