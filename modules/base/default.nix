{ lib, pkgs, ... }:

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

  # Bootloader — all nodes use UEFI/OVMF
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Nix settings
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
    require-sigs = false;
  };

  # Serial console — enables virsh console access
  boot.kernelParams = [ "console=ttyS0" ];

  # Admin user with SSH key from midir
  users.users.nixos = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE+qTeCq+AnE6mCD6/9kFe4wR0VAC1BfvkrYw8MnpQbS pybashinf@gmail.com"
    ];
  };

  security.sudo.wheelNeedsPassword = false;

  system.stateVersion = "25.05";
}
