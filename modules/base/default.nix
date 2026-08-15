{ config, lib, pkgs, ... }:

{
  # Locale and timezone
  time.timeZone = lib.mkDefault "Europe/Madrid";
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";

  # Minimal base packages
  environment.systemPackages = with pkgs; [
    git
    curl
    htop
    vim
  ];

  # SSH hardening
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # Firewall — allow SSH only by default; profiles open additional ports
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
  };

  # Nix settings
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  system.stateVersion = "25.05";
}
