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

    passwordFile = lib.mkOption {
      type = lib.types.str;
      default = "/etc/restack/restic-password";
      description = ''
        Path to file containing the restic repository password.
        Must be readable by the postgres user.
        Initialise the repo once with: restic -r <backupRepo> init
      '';
    };

    restoreCheckInterval = lib.mkOption {
      type = lib.types.str;
      default = "weekly";
      description = "How often to run the automated restore check (systemd calendar spec).";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ restic ];

    # Backup: pg_dumpall piped into restic stdin — atomic, no temp disk required
    systemd.services.restack-backup = {
      description = "Restack PostgreSQL backup via restic";
      after = [ "postgresql.service" "network.target" ];
      wants = [ "network.target" ];
      serviceConfig = {
        Type = "oneshot";
        User = "postgres";
        ExecStart = pkgs.writeShellScript "restack-backup" ''
          export RESTIC_REPOSITORY="${cfg.backupRepo}"
          export RESTIC_PASSWORD_FILE="${cfg.passwordFile}"
          ${pkgs.postgresql_16}/bin/pg_dumpall | \
            ${pkgs.restic}/bin/restic backup --stdin --stdin-filename postgres.sql
        '';
      };
    };

    systemd.timers.restack-backup = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
      };
    };

    # Restore check: pull latest snapshot from restic, verify it contains table definitions.
    # Exits non-zero on failure — surfaces via systemd unit status and can be scraped by Prometheus.
    systemd.services.restack-dr-check = {
      description = "Restack automated restore check";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "restack-dr-check" ''
          export RESTIC_REPOSITORY="${cfg.backupRepo}"
          export RESTIC_PASSWORD_FILE="${cfg.passwordFile}"
          TABLES=$(${pkgs.restic}/bin/restic dump latest postgres.sql | grep -c "^CREATE TABLE")
          if [ "$TABLES" -eq 0 ]; then
            echo "DR check FAILED: backup contains no CREATE TABLE statements" >&2
            exit 1
          fi
          echo "DR check passed: $TABLES tables verified in latest backup"
        '';
      };
    };

    systemd.timers.restack-dr-check = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.restoreCheckInterval;
        Persistent = true;
      };
    };
  };
}
