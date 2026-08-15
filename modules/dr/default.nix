{ config, lib, pkgs, ... }:

let
  cfg = config.restack.dr;
in
{
  options.restack.dr = {
    enable = lib.mkEnableOption "Restack verifiable DR module";

    backupRepo = lib.mkOption {
      type = lib.types.str;
      description = "Restic backup repository path or URL.";
    };

    restoreCheckInterval = lib.mkOption {
      type = lib.types.str;
      default = "weekly";
      description = "How often to run the automated restore check.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ restic ];

    # Backup timer
    systemd.timers.restack-backup = {
      wantedBy = [ "timers.target" ];
      timerConfig.OnCalendar = "daily";
    };

    systemd.services.restack-backup = {
      description = "Restack restic backup";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.restic}/bin/restic backup /var/lib/postgresql";
      };
    };

    # Restore check timer — this is the verifiable DR property
    systemd.timers.restack-dr-check = {
      wantedBy = [ "timers.target" ];
      timerConfig.OnCalendar = cfg.restoreCheckInterval;
    };

    systemd.services.restack-dr-check = {
      description = "Restack automated restore check";
      serviceConfig = {
        Type = "oneshot";
        # Restore to a scratch location and verify integrity
        # Exits non-zero on failure — surfaced via systemd unit status / Prometheus
        ExecStart = "${pkgs.restic}/bin/restic restore latest --target /tmp/dr-check --verify";
      };
    };
  };
}
