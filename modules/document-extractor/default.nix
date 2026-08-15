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

  # Placeholder — Alessandro's prototype to be wired in here
  # Package derivation will live in pkgs/document-extractor/
  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ cfg.port ];

    # systemd.services.document-extractor = { ... };
  };
}
