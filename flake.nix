{
  description = "Restack — reproducible self-hosting infrastructure stack";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
  };

  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      nixosConfigurations = {

        # Personal profile — single node, document extractor
        nix-node-1 = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./hosts/nix-node-1
            ./profiles/personal
          ];
        };

        # Organisational profile — HA primary
        nix-node-2 = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./hosts/nix-node-2
            ./profiles/organisational
            { restack.ha.role = "primary"; }
          ];
        };

        # Organisational profile — HA replica
        nix-node-3 = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./hosts/nix-node-3
            ./profiles/organisational
            { restack.ha.role = "replica"; }
          ];
        };

      };

      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          nixos-rebuild
          nixfmt-rfc-style
          reuse
        ];
      };
    };
}
