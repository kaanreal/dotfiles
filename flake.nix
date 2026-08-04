{
  description = "kaan's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    caelestia-shell.url = "github:caelestia-dots/shell";

    # CachyOS kernel (removed from nixpkgs; provided by xddxdd's flake)
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel";
  };

  outputs = {
    nixpkgs,
    home-manager,
    caelestia-shell,
    nix-cachyos-kernel,
    ...
  }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        inherit nix-cachyos-kernel;
      };
      modules = [
        ./nixos/hosts/nixos
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = {
            inherit caelestia-shell home-manager;
          };
          home-manager.users.kaan = import ./nixos/home/kaan;
        }
      ];
    };
  };
}
