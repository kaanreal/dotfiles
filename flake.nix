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

  outputs =
    {
      nixpkgs,
      home-manager,
      caelestia-shell,
      nix-cachyos-kernel,
      ...
    }:
    {
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

      # Optional standalone home-manager output (e.g. for a future non-NixOS
      # machine). The NixOS workflow uses nh os switch and does not depend on
      # running `home-manager switch` separately.
      homeConfigurations.kaan = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
          overlays = [ nix-cachyos-kernel.overlays.default ];
        };
        modules = [
          ./nixos/home/kaan
        ];
        extraSpecialArgs = {
          inherit caelestia-shell home-manager;
        };
      };
    };
}
