{
  description = "kaan's cozy home — one repo for NixOS, dotfiles, and every machine";

  inputs = {
    # Pinned: newer nixpkgs snapshots ship a broken Hyprland (0.56.1 builds
    # fail: it tries to clone `glaze` via CMake FetchContent inside the offline
    # Nix sandbox). 1559d3d built generation 53 cleanly. Un-pin once upstream
    # nixpkgs fixes the Hyprland build.
    nixpkgs.url = "github:NixOS/nixpkgs/1559d3daa3ecc813a650b79375ea61b6741b8746";

    # Pinned: home-manager master snapshots newer than this may require a newer
    # nixpkgs than 1559d3d. Bump together with nixpkgs once the pin is removed.
    home-manager = {
      url = "github:nix-community/home-manager/bf9ce9fec78f95f374e8dd3b503863a3ec128ebe";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Pinned: caelestia-shell 68821bfd+ ships quickshell 0.3.0 whose wrapped
    # build trips "detected mismatched Qt dependencies". 046dd3c (with its
    # locked quickshell 10b439fc) built generation 53 cleanly.
    caelestia-shell.url = "github:caelestia-dots/shell/046dd3c6c3b1782f27284d5fc0e181b6021dd7c7";

    # CachyOS kernel (removed from nixpkgs; provided by xddxdd's flake)
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/0c30753ac307cd4656848c367a1c188374d892c0";
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
          ./hosts/nixos-desktop
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              inherit caelestia-shell home-manager;
            };
            home-manager.users.kaan = import ./nix/home/kaan;
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
          ./nix/home/kaan
        ];
        extraSpecialArgs = {
          inherit caelestia-shell home-manager;
        };
      };
    };
}
