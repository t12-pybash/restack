{ config, lib, pkgs, ... }:

let
  cfg = config.restack.documentExtractor;
in
{
  options.restack.documentExtractor = {
    enable = lib.mkEnableOption "Restack document extractor";

    port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description = "Port the document extractor service listens on.";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ cfg.port ];

    systemd.services.document-extractor = {
      description = "Restack document extractor (Apache Tika server)";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.tika}/bin/tika-server -p ${toString cfg.port}";
        Restart = "on-failure";
        RestartSec = "5s";
        DynamicUser = true;
        StateDirectory = "document-extractor";
      };
    };
  };
}
