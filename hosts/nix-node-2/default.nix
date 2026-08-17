{ ... }:

{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "nix-node-2";
  networking.useDHCP = false;
  networking.interfaces.enp1s0.ipv4.addresses = [{
    address = "192.168.122.101";
    prefixLength = 24;
  }];
  networking.defaultGateway = "192.168.122.1";
  networking.nameservers = [ "8.8.8.8" "1.1.1.1" ];
}
